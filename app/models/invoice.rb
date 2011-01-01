# Most of the tax booking functionality is required here.
require 'tax_bookers/tax_booker'

class Invoice < ActiveRecord::Base

  # === Associations
  
  belongs_to :user
  has_many :invoice_lines
  belongs_to :order
  
  belongs_to :shipping_address, :polymorphic => true
  belongs_to :billing_address, :polymorphic => true
  belongs_to :payment_method
  
  
  # === Validations
  
  validates_presence_of :billing_address
  validates_associated :billing_address, :message => 'is incomplete'

  
  # === AR Callbacks
  
  before_create :assign_uuid
  before_validation :move_paid_status
  after_create :record_income 
  
  # === Constants and associated methods
    
  UNPAID = 1
  PAID = 2
  
  STATUS_HASH = { UNPAID     => I18n.t('stizun.constants.unpaid'),
                  PAID       => I18n.t('stizun.constants.paid')}

  # === Named scopes

  scope :unpaid, :conditions => { :status_constant => Invoice::UNPAID }
  scope :paid, :conditions => { :status_constant => Invoice::PAID }

  
  # === Methods
  
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
  
  def status_human
    return Invoice::status_to_human(status_constant)
  end

  def document_id
    return "I-#{document_number}"
  end

  def taxed_price
    return invoice_lines.sum("taxed_price") + shipping_cost
  end

  def gross_price
    return invoice_lines.sum("gross_price")
  end
  
  # Alias for order_lines so that generic (order|invoice).lines works
  def lines
    invoice_lines
  end

  def weight
    weight = 0.0
    lines.each do |l|
      weight += l.quantity * l.weight unless l.weight.blank?
    end
    return weight
  end
  
  def taxes
    product_taxes = lines.sum('taxes')
    return product_taxes + shipping_taxes
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
       self.order_id = order.id
       self.document_number = order.document_number
       self.payment_method_id = order.payment_method_id
       self.billing_address_type = order.billing_address_type
       self.shipping_address_type = order.shipping_address_type
       self.billing_address = order.billing_address
       self.shipping_address = order.shipping_address
       self.shipping_cost = order.shipping_rate.total_cost.rounded
       self.shipping_taxes = order.shipping_rate.total_taxes
       self.status_constant = Invoice::UNPAID
       self.invoice_lines_from_order(order)
       order.update_attributes(:status_constant => Order::AWAITING_PAYMENT)
    end    
  end
  
  # The same, but works with an existing Invoice object
  def invoice_lines_from_order(order)
    invoice = self
    order.order_lines.each do |ol|
      
      il = InvoiceLine.new
      il.quantity = ol.quantity
      il.text = ol.product.name
      il.taxed_price = ol.taxed_price.rounded      
      il.gross_price = ol.gross_price
      il.single_price = ol.product.price.rounded
      il.tax_percentage = ol.product.tax_class.percentage
      il.taxes = ol.taxes
      il.weight = ol.product.weight
      invoice.invoice_lines << il
    end
    return invoice
  end
  
  
  # Unfortunate duplication introduced by the splitting of Invoices from Documents.
  # must be refactored.
  def notification_email_addresses
    emails = []
    if self.billing_address.email.blank? and self.shipping_address.email.blank? and !self.user.nil?
      emails << self.user.email
    elsif self.shipping_address.nil? and !self.billing_address.email.blank?
      emails << self.billing_address.email
    else
      if (!self.user.nil? and !self.user.email.blank?)
        emails << self.user.email
      end
      emails << self.billing_address.email unless self.billing_address.email.blank?
      emails << self.shipping_address.email unless self.shipping_address.email.blank?
    end
    
    return emails.uniq
  end

  # ActiveRecord before_* and after_* callbacks
  
  def assign_uuid
    self.uuid = UUIDTools::UUID.random_create.to_s
    self.document_number ||= Numerator.get_number
  end
  
  def move_paid_status
    # This is not a transformation, it's just to prevent accounting problems, an invoice
    # should never make this transformation.
    if self.status_constant_was == Invoice::PAID and self.status_constant == Invoice::UNPAID
      errors.add(:invoice, "Paid invoices can never be set to unpaid.")
      return false
    end
  end
  
  # This invoice was paid -- record its payment in
  # the accounting system
  def record_payment_transaction
   
    # TODO: Catch and prevent multiple payment bookings on the same invoice
    if self.order
      # The order is now ready to ship since it was paid
      self.order.update_attributes(:status_constant => Order::TO_SHIP) if self.order.status_constant == Order::AWAITING_PAYMENT
    end
    
    # Book the correct entries for payment of this invoice
    if self.user.blank?
      user_account = Account.get_anonymous_account(self.billing_address)
    else
      user_account = self.user.get_account
    end
    
    bank_account = Account.find_by_id(ConfigurationItem.get("bank_account_id").value)
    
    if AccountTransaction.transfer(bank_account, user_account, self.taxed_price, "Invoice payment #{self.document_id}", self)
      History.add("Payment transaction for invoice #{self.document_id}. Credit: Bank account #{self.taxed_price}", History::ACCOUNTING, self)
    else
      History.add("Failed creating payment transaction for #{self.document_id}. Credit: Bank account #{self.taxed_price}", History::ACCOUNTING,  self)                         
    end
  end
  
  def record_income
    # OPTIMIZE: May need to map _all_ accounts to addresses instead of users.
    # that way only one kind of account needs to be handled and we can introduce
    # a direct association between addresses and accounts.
    if self.user.blank?
      user_account = Account.get_anonymous_account(self.billing_address)
    else
      user_account = self.user.get_account
    end

    self.transaction do
      sales_income_account = Account.find(ConfigurationItem.get('sales_income_account_id').value)
      
      res = AccountTransaction.transfer(user_account, sales_income_account, self.taxed_price, "Invoice #{self.document_id}", self)
      TaxBookers::TaxBooker.record_invoice(self)
    end
  end

end
