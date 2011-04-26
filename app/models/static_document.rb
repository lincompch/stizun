class StaticDocument < ActiveRecord::Base
  self.abstract_class = true

  # === Associations
  
  belongs_to :user
  
  belongs_to :shipping_address, :polymorphic => true
  belongs_to :billing_address, :polymorphic => true
  belongs_to :payment_method
  
  
  # === Validations
  
  validates_presence_of :billing_address
  validates_associated :billing_address, :message => 'is incomplete'

  # === AR Callbacks
  
  before_create :assign_uuid

  # === Methods
  
  def taxed_price
    return lines.sum("taxed_price") + shipping_cost
  end

  def gross_price
    return lines.sum("gross_price")
  end
  
  def products_taxed_price
    return lines.sum("taxed_price")
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
    return product_taxes
  end

  def total_taxes
    taxes + shipping_taxes
  end
  
  def products
    self.lines.collect(&:product).compact
  end
  
  def suppliers
    products.collect(&:supplier).uniq
  end
  
  def lines_by_supplier(supplier)
    supplier_lines = []
    lines.each do |line|
      supplier_lines << line if !line.product.blank? and line.product.supplier == supplier
    end
    return supplier_lines
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
  
  
end
