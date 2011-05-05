# Most of the tax booking functionality is required here.
require 'tax_bookers/tax_booker'

class Invoice < StaticDocument

  # === Associations
  
  belongs_to :user
  has_many :invoice_lines
  belongs_to :order
  
  has_one :replacement, :class_name => 'Invoice', :foreign_key => 'replacement_id'
  
  # === AR Callbacks
  
  before_validation :move_paid_status
  
  # === Constants and associated methods
    
  UNPAID = 1
  PAID = 2
  CANCELED = 3
  
  STATUS_HASH = { UNPAID     => 'stizun.constants.unpaid',
                  PAID       => 'stizun.constants.paid',
                  CANCELED  => 'stizun.constants.canceled'}

  # === Named scopes

  scope :unpaid, :conditions => { :status_constant => Invoice::UNPAID }
  scope :paid, :conditions => { :status_constant => Invoice::PAID }
  scope :canceled, :conditions => { :status_constant => Invoice::CANCELED }

  
  # === Methods
  
  def self.status_to_human(status)
    # Gotta call I18n.t like this because it doesn't have the correct
    # locale set outside this definition on _some_ installations, not all.
    # Possibly broken in Rails.    
    return I18n.t(STATUS_HASH[status])
  end
  
  def self.status_hash_for_select
    hash = []
    STATUS_HASH.each do |key,value|
      hash << [I18n.t(value), key]
    end 
    return hash

  end
  
  def status_human
    return Invoice::status_to_human(status_constant)
  end

  def document_id
    return "I-#{document_number}"
  end

  # Alias for order_lines so that generic (order|invoice).lines works
  def lines
    invoice_lines
  end
  
  # Static method, should be used whenever creating an invoice
  # based on a pre-existing order, e.g. during checkout
  def self.create_from_order(order)
    invoice = self.new_from_order(order)
    invoice.save
    return invoice
  end
  
  def self.new_from_order(order)
    invoice = self.new
    invoice.clone_from_order(order)
    return invoice
  end
  
  # This is the central method that copies an order's details
  # into an invoice. Other methods should call this one if the same thing is desired.
  def clone_from_order(order)
    if order.invoiced?
      raise ArgumentError, "The supplied order is already invoiced."
    else
       self.user_id = order.user_id
       self.order = order
       self.document_number = order.document_number
       self.payment_method_id = order.payment_method_id
       self.billing_address_type = order.billing_address_type
       self.shipping_address_type = order.shipping_address_type
       self.billing_address = order.billing_address
       self.shipping_address = order.shipping_address
       self.shipping_cost = order.shipping_cost
       self.shipping_taxes = order.shipping_taxes
       self.rebate = order.rebate
       self.status_constant = Invoice::UNPAID
       self.invoice_lines_from_order(order)
    end    
  end
  
  # The same, but works with an existing Invoice object
  def invoice_lines_from_order(order)
    invoice = self
    order.order_lines.each do |ol|
      # order_lines are static_document_lines, so they can be assigned to an invoice
      # at the same time, ensuring that the invoice always reflects the order 100%.
      ol.invoice = invoice
      ol.save
    end
    return invoice
  end

  # Creates a replacement invoice so that any rebates that might be applied to an order can invalidate
  # the old invoice and automatically make it point at the replacement
  def create_replacement
    new_invoice = self.clone
    new_invoice.document_number = Numerator.get_number
    old_invoice = self
    old_invoice.status_constant = Invoice::CANCELED
    old_invoice.order_id = nil
    old_invoice.lines.each do |line|
      new_invoice.invoice_lines << line.clone
      line.order_id = nil # Disassociate the order so that things don't appear twice on orders just because there is a replacement invoice
      line.save
    end
    new_invoice.save
    old_invoice.replacement = new_invoice
    old_invoice.save
    return new_invoice
  end
  
  # ActiveRecord before_* and after_* callbacks
  
  def move_paid_status
    # This is not a transformation, it's just to prevent accounting problems, an invoice
    # should never make this transformation.
    if self.status_constant_was == Invoice::PAID and self.status_constant == Invoice::UNPAID
      errors.add(:invoice, "Paid invoices can never be set to unpaid.")
      return false
    end
  end
  

end
