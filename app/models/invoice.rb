# Most of the tax booking functionality is required here.
require 'tax_bookers/tax_booker'

class Invoice < StaticDocument

  # === Associations
  
  belongs_to :user
  has_many :invoice_lines
  belongs_to :order
  
  # === AR Callbacks
  
  before_save :handle_autobooking
  before_validation :move_paid_status
  after_create :record_income
  
  # === Constants and associated methods
    
  UNPAID = 1
  PAID = 2
  
  STATUS_HASH = { UNPAID     => 'stizun.constants.unpaid',
                  PAID       => 'stizun.constants.paid'}

  # === Named scopes

  scope :unpaid, :conditions => { :status_constant => Invoice::UNPAID }
  scope :paid, :conditions => { :status_constant => Invoice::PAID }

  
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

  # ActiveRecord before_* and after_* callbacks
  
  def move_paid_status
    # This is not a transformation, it's just to prevent accounting problems, an invoice
    # should never make this transformation.
    if self.status_constant_was == Invoice::PAID and self.status_constant == Invoice::UNPAID
      errors.add(:invoice, "Paid invoices can never be set to unpaid.")
      return false
    end
  end
  
  def handle_autobooking
    # Only record the transaction if this invoice was unpaid before and
    # if autobooking is desired for this invoice.
    
    # TODO: Also check whether the order relating to this invoice is even here, and
    # whether it was paid already before.
    if autobook == true and \
       status_constant_was == Invoice::UNPAID and \
       status_constant == Invoice::PAID
      record_payment_transaction
    end
  end
  
  # This invoice was paid -- record its payment in
  # the accounting system. This should only be done for invoices that have autobooking enabled.
  def record_payment_transaction
    
    # Book the correct entries for payment of this invoice
    if self.user.blank?
      user_account = Account.get_anonymous_account(self.billing_address)
    else
      user_account = self.user.get_account
    end
    
    bank_account = Account.find_by_id(ConfigurationItem.get("bank_account_id").value)
    
    if AccountTransaction.transfer(bank_account, user_account, self.taxed_price, "Invoice payment #{self.document_id}", self)
      History.add("Payment transaction for invoice #{self.document_id}. Credit: Bank account #{self.taxed_price}", History::ACCOUNTING, self)
         
      if self.order
        # The order is now ready to ship since it was paid
        self.order.update_attributes(:status_constant => Order::TO_SHIP) if self.order.status_constant == Order::AWAITING_PAYMENT
      end
      
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

      require 'net/smtp'
      begin
        StoreMailer.invoice(self).deliver
      rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
        History.add("Could not send invoice confirmation for #{self.document_id} during checkout: #{e.to_s}", History::GENERAL, self)
      end
    end
  end
end
