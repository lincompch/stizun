class Order < StaticDocument

  # === Associations
  belongs_to :user
  has_many :order_lines
  has_one :invoice 
  belongs_to :shipping_carrier
  has_many :tracking_codes
  accepts_nested_attributes_for :tracking_codes, :allow_destroy => true, :reject_if =>  proc { |attributes| attributes['shipping_carrier_id'].blank? }

  # === Validations

  #validates_presence_of :billing_address
  
  validates_associated :billing_address, :message => I18n.t('stizun.address.is_incomplete')
  validates_associated :shipping_address, :unless => :addressing_ok?, :message => I18n.t('stizun.address.is_incomplete')
  
  validates_acceptance_of :terms_of_service, :on => :create, :message => I18n.t("stizun.order.terms_must_be_accepted")
  
  validate :must_be_authorized_for_payment_method
  
  
  # === Callbacks
  
  after_initialize :assign_payment_method, :assign_document_number 
  before_save :send_shipping_notification, :normalize_rebate, :replace_invoice_on_rebate_change, :cancel_associated_invoices_on_cancellation
  
  # This doesn't seem to work at all, or at least not as advertised
  # Might be fixed in Rails 3.0 (polymorphic association + nested forms)
  #accepts_nested_attributes_for :shipping_address
  #accepts_nested_attributes_for :billing_address

  
  # === Constants and associated methods

  # Rails 3.0 will have ActiveRecord.state_machine that will
  # take care of this better (with transitions), but we 
  # cannot use that in 2.3. We might want to look into has_states
  # at some point: http://github.com/sbfaulkner/has_states
  UNPROCESSED = 1
  PROCESSING = 2
  AWAITING_PAYMENT = 3
  SHIPPED = 4
  TO_SHIP = 5
  CANCELED = 6
  
  STATUS_HASH = { UNPROCESSED      => 'stizun.constants.unprocessed',
                  PROCESSING       => 'stizun.constants.processing',
                  AWAITING_PAYMENT => 'stizun.constants.awaiting_payment',
                  TO_SHIP          => 'stizun.constants.to_ship',
                  SHIPPED          => 'stizun.constants.shipped',
                  CANCELED         => 'stizun.constants.canceled' }

  def self.status_to_human(status)
    # Gotta call I18n.t like this because it doesn't have the correct
    # locale set outside this definition on _some_ installations, not all.
    # Possibly broken in Rails.
    return I18n.t(STATUS_HASH[status])
  end
  
  def self.status_hash_for_select
    array = []
    STATUS_HASH.each do |key,value|
      array << [I18n.t(value), key]
    end 
    # Sort by value of the constant integer, so the sequence of
    # statuses is more or less the same as it appears in the
    # workflow.
    return array.sort {|a, b| a[1] <=> b[1]}
  end
  
  def status_human
    return Order::status_to_human(status_constant)
  end  
  
  # === Named scopes
  
  scope :unprocessed, :conditions => { :status_constant => Order::UNPROCESSED }
  scope :processing, :conditions => { :status_constant => Order::PROCESSING }
  scope :awaiting_payment, :conditions => { :status_constant => Order::AWAITING_PAYMENT }
  scope :shipped, :conditions => { :status_constant => Order::SHIPPED }
  scope :to_ship, :conditions => { :status_constant => Order::TO_SHIP }
  scope :canceled, :conditions => { :status_constant => Order::CANCELED }

  scope :pending_from_user_perspective, :conditions => "status_constant == ?" # TODO: is this working yet?
  
  # TODO: Verify if this is working
  before_save { |record|
    if record.shipping_address.blank?
      record.shipping_address = record.billing_address
    end
  }
  
  # === Methods
  
  def invoiced?
    return !invoice.blank?
  end

  def has_tracking_information?
    tracking_codes.count > 0
    #!tracking_number.blank? && !shipping_carrier_id.nil?
  end
  
  def document_id
    return "O-#{document_number}"
  end
  
  def self.new_from_cart(cart)    
    order = self.new
    order.clone_from_cart(cart)
    return order
  end
  
  def clone_from_cart(cart)
    raise ArgumentError, "clone_from_cart can only work with objects of type Cart" unless cart.class.name == "Cart"
    self.shipping_cost = cart.shipping_cost
    self.shipping_taxes = cart.shipping_taxes
    self.rebate = BigDecimal.new("0.0") # Shouldn't be necessary because the DB default is 0.0, but better safe than sorry
    self.order_lines_from_cart(cart)
    return self
  end
  
  
  def order_lines_from_cart(cart)
    cart.cart_lines.each do |cl|
      ol = OrderLine.new
      ol.quantity = cl.quantity
      ol.text = cl.product.name
      ol.product = cl.product
      ol.single_untaxed_price = cl.product.gross_price
      ol.tax_percentage = cl.product.tax_class.percentage
      ol.taxes = cl.taxes # cl.product.taxes
      ol.manufacturer = cl.product.manufacturer
      ol.manufacturer_product_code = cl.product.manufacturer_product_code
      ol.weight = cl.product.weight
      self.order_lines << ol
    end
    return self
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
  # TODO: This is probably no longer necessary now that we save invoices
  # as lists of independent text strings instead of using product
  # references.
  def locked?
    locked = false
    status_constant == Order::UNPROCESSED ? locked = false : locked = true
    locked = true unless invoice.blank?
    return locked
  end
  
  
  # If the user doesn't actually have authorization for this payment method, e.g. a user
  # who must pre-pay tries to order something on credit, the order can't be saved.
  # It should actually never be possible for a user to pass an unauthorized payment type,
  # but this check prevents errors e.g. from admins manipulating orders on the console.
  def must_be_authorized_for_payment_method
    authorized_methods = []
    authorized_methods << PaymentMethod.get_default
    authorized_methods += user.payment_methods if user

    unless authorized_methods.uniq.include?(payment_method)
      errors.add_to_base("User is not authorized for the chosen payment method.")
    end
    
  end
  
  def send_order_confirmation(user)
    # Is this require really required? Just to have some errors
    # that we can rescue?
    require 'net/smtp'
    begin
      StoreMailer.order_confirmation(user, self).deliver
    rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
      History.add("Could not send order confirmation for order  #{self.document_id} during checkout: #{e.to_s}", History::GENERAL, self)
    end
  end
  
  # This can be a simple change of the constant because the before_save
  # callback takes care of setting associated invoices to canceled
  def cancel
    self.update_attributes(:status_constant => Order::CANCELED)
  end
  
  # === ActiveRecord callbacks

  def normalize_rebate
    # Normalize this, we don't want nil values in the rebate field because that's
    # used in very central bits of code.
    self.rebate = BigDecimal.new("0.0") if self.rebate.nil?
    self.rebate = self.rebate
  end

  # If a new rebate is added to this order, of course the old invoice becomes invalid
  # and needs to be replaced with a new one
  def replace_invoice_on_rebate_change
    if self.rebate_changed? and !self.invoice.blank?
      new_invoice = self.invoice.create_replacement
      self.invoice = new_invoice
      self.invoice.rebate = self.rebate
      self.invoice.save
    end
  end
    
  def assign_payment_method
    self.payment_method ||= PaymentMethod.get_default
  end
  
  def assign_document_number
    self.document_number ||= Numerator.get_number
  end
    
  def cancel_associated_invoices_on_cancellation
    # Order went from any other state than canceled to canceled
    previous_status = STATUS_HASH.keys - [CANCELED]
    if previous_status.include?(status_constant_was) && status_constant == CANCELED
      self.invoice.cancel unless self.invoice.blank?
    end
  end
  
  def send_shipping_notification
    # Order went from something else to SHIPPED, let's send a notification
    
    previous_status = [UNPROCESSED, PROCESSING, AWAITING_PAYMENT, TO_SHIP]
    if previous_status.include?(status_constant_was) && status_constant == SHIPPED
      # Is this require really required? Just to have some errors
      # that we can rescue?
      require 'net/smtp'
      begin
        StoreMailer.shipping_notification(self).deliver
      rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
        History.add("Could not send shipping notification for order  #{self.document_id}: #{e.to_s}", History::GENERAL, self)
      end
    end
  end

  def invoice_order
    unless self.new_record?
      invoice = Invoice.new_from_order(self)
      if invoice.save
        self.update_attributes({:status_constant => Order::AWAITING_PAYMENT})
      else
        History.add("Could not create invoice for order #{self.document_id} during checkout, must manually invoice this.", History::ACCOUNTING, self)
      end
    else
      raise ArgumentError, "Can't create an associated invoice unless this order is saved first."
    end
  end

  def self.process_automatic_cancellations
    Order.awaiting_payment.each do |o|
      if o.auto_cancel == true and o.created_at < (DateTime.now - 10.days)
        o.cancel
        StoreMailer.auto_cancellation(o).deliver
      end
    end
  end
  
end
