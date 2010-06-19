class Order < Document

  belongs_to :user
  has_many :order_lines
  has_one :invoice 
  
  belongs_to :shipping_address, :polymorphic => true
  belongs_to :billing_address, :polymorphic => true
  belongs_to :payment_method
  
  validates_presence_of :billing_address
  
  validates_associated :billing_address, :message => 'is incomplete'
  validates_associated :shipping_address, :unless => :addressing_ok?, :message => 'is incomplete'
  
  validate :must_be_authorized_for_payment_method
  
  # This doesn't seem to work at all, or at least not as advertised
  # Might be fixed in Rails 3.0 (polymorphic association + nested forms)
  #accepts_nested_attributes_for :shipping_address
  #accepts_nested_attributes_for :billing_address

  
  # Status constants
  # Rails 3.0 will have ActiveRecord.state_machine that will
  # take care of this better (with transitions), but we 
  # cannot use that in 2.3. We might want to look into has_states
  # at some point: http://github.com/sbfaulkner/has_states
  UNPROCESSED = 1
  PROCESSING = 2
  AWAITING_PAYMENT = 3
  SHIPPED = 4
  TO_SHIP = 5
  
  STATUS_HASH = { UNPROCESSED      => 'Unprocessed',
                  PROCESSING       => 'Processing',
                  AWAITING_PAYMENT => 'Awaiting payment',
                  TO_SHIP          => 'To ship',
                  SHIPPED          => 'Shipped'}

  
  named_scope :unprocessed, :conditions => { :status_constant => Order::UNPROCESSED }
  named_scope :processing, :conditions => { :status_constant => Order::PROCESSING }
  named_scope :awaiting_payment, :conditions => { :status_constant => Order::AWAITING_PAYMENT }
  named_scope :shipped, :conditions => { :status_constant => Order::SHIPPED }
  named_scope :to_ship, :conditions => { :status_constant => Order::TO_SHIP }
  
  named_scope :pending_from_user_perspective, :conditions => "status_constant == ?"
  
  # TODO: Verify if this is working
  before_save { |record|
    if record.shipping_address.blank?
      record.shipping_address = record.billing_address
    end
  }
  
  
  def self.status_to_human(status)
    return STATUS_HASH[status]
  end
  
  def self.status_hash_for_select
    hash = []
    STATUS_HASH.each do |key,value|
      hash << [value, key]
    end 
    return hash

  end
  
  def after_initialize
    self.payment_method ||= PaymentMethod.get_default
  end
  
  def status_human
    return Order::status_to_human(status_constant)
  end
  
  def invoiced?
    return !invoice.blank?
  end

  def document_id
    return "O-#{document_number}"
  end
  
  # Static method, should be used whenever creating an order
  # based on a pre-existing cart, e.g. during checkout
  def self.create_from_cart(cart)
    order = self.new
    order.order_lines_from_cart(cart)
    return order
  end
  
  # The same, but works with an existing Order object
  def order_lines_from_cart(cart)
    order = self
    cart.cart_lines.each do |cl|
      ol = OrderLine.create(cl.attributes)
      ol.cart_id = nil
      order.order_lines << ol
    end
    return order
  end
  
    
  
  # This is used in validation.
  # If neither address is filled in, validate both.
  # If only the billing address is filled in, validate just that
  def addressing_ok?
    if billing_address.nil?
      return false
    elsif billing_address.filled_in? and (shipping_address.nil? or !shipping_address.filled_in?)
      return true
    elsif billing_address.filled_in? and shipping_address.filled_in?
      return false
    else
      return false
    end
  end
  
  # Alias for order_lines so that generic order|invoice.lines works
  def lines
    order_lines
  end

  
  # A locked order's order_lines may not be changed anymore.
  # This is to prevent invoiced orders from being changed, otherwise
  # the invoice would no longer be correct.
  def locked?
    locked = false
    status_constant == Order::UNPROCESSED ? locked = false : locked = true
    locked = true unless invoice.blank?
    return locked
  end
  
  def direct_shipping?
    direct = true
    direct = false if lines.collect(&:product).collect(&:direct_shipping).include?(false)
    direct = false if payment_method.allows_direct_shipping == false
    return direct
  end
  
  def must_be_authorized_for_payment_method
 
    unless payment_method == PaymentMethod.get_default or user.payment_methods.include?(payment_method) or  
      errors.add_to_base("User is not authorized for the chosen payment method.")
    end
    
  end
  
  def before_create
    self.document_number ||= Numerator.get_number
  end
  
  
  
end
