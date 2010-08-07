class Invoice < ActiveRecord::Base

  belongs_to :user
  has_many :invoice_lines
  belongs_to :order
  
  belongs_to :shipping_address, :polymorphic => true
  belongs_to :billing_address, :polymorphic => true
  belongs_to :payment_method
  
    
  validates_presence_of :billing_address
  validates_associated :billing_address, :message => 'is incomplete'

    
  UNPAID = 1
  PAID = 2
  
  STATUS_HASH = { UNPAID     => 'Unpaid',
                  PAID       => 'Paid'}


  named_scope :unpaid, :conditions => { :status_constant => Invoice::UNPAID }
  named_scope :paid, :conditions => { :status_constant => Invoice::PAID }

  
  
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
  
  # Backwards compatibility alias -- to remove in refactoring.
  def rounded_price
    price
  end
  
  def price
    total = 0
    self.invoice_lines.each do |il|
      total += il.rounded_price
    end
    total += shipping_cost
    return total
  end

  
  # Alias for order_lines so that generic order|invoice.lines works
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
    lines.sum('taxes')
  end
  
  # Static method, should be used whenever creating an invoice
  # based on a pre-existing order, e.g. during checkout
  def self.create_from_order(order)
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
      
       self.order_id = order.id
       self.document_number = order.document_number
       self.payment_method_id = order.payment_method_id
       self.billing_address_type = order.billing_address_type
       self.shipping_address_type = order.shipping_address_type
       self.billing_address = order.billing_address
       self.shipping_address = order.shipping_address
       self.user_id = order.user_id
       self.shipping_cost = order.shipping_rate.total_cost
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
      il.rounded_price = ol.rounded_price
      il.single_rounded_price = ol.product.rounded_price
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
      emails << self.billing_address.email unless self.billing_address.email.blank?
      emails << self.shipping_address.email unless self.shipping_address.email.blank?
    end
    
    return emails.uniq
  end

  # ActiveRecord before_* and after_* callbacks
  def before_create
    self.uuid = UUIDTools::UUID.random_create.to_s
    self.document_number ||= Numerator.get_number
  end
  
  def before_validation
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
    
    cash_account = Account.find_by_id(ConfigurationItem.get("cash_account_id").value)
    if AccountTransaction.transfer(cash_account, user_account, self.rounded_price, "Invoice payment #{self.document_id}", self)
      History.add("Payment transaction for invoice #{self.document_id}. Credit: Cash account #{self.rounded_price}", self)                         
    else
      History.add("Failed creating transaction for #{self.document_id}. Credit: Cash account #{self.rounded_price}", self)                         
    end
  end
  
  def after_create
    # OPTIMIZE: May need to map _all_ accounts to addresses instead of users.
    # that way only one kind of account needs to be handled and we can introduce
    # a direct association between addresses and accounts.
    if self.user.blank?
      account = Account.get_anonymous_account(self.billing_address)
    else
      account = self.user.get_account
    end
    AccountTransaction.transfer(account, Account.find_by_name("Warenertrag"), self.rounded_price, "Invoice #{self.document_id}", self)
    History.add("Transaction for invoice #{self.document_id}. Credit: #{account.name} #{self.rounded_price}", self)
  end
  
end
