class SupplyItem < ActiveRecord::Base
  
  belongs_to :tax_class
  belongs_to :supplier
  has_one :product
  
  before_create :set_status_to_available_if_nil
  before_save :handle_supply_item_deletion
  
  def self.per_page
    return 100
  end
  
  # === Constants and associated methods
    
  AVAILABLE = 1
  DELETED = 2
  
  STATUS_HASH = { AVAILABLE => 'stizun.constants.available',
                  DELETED   => 'stizun.constants.deleted'}

  def self.status_to_human(status)
    # Gotta call I18n.t like this because it doesn't have the correct
    # locale set outside this definition on _some_ installations, not all.
    # Possibly broken in Rails.    
    if status.blank?
      return "not set"
    else
      return I18n.t(STATUS_HASH[status])
    end
  end
  
  def self.status_hash_for_select
    hash = []
    STATUS_HASH.each do |key,value|
      hash << [I18n.t(value), key]
    end 
    return hash

  end
  
  def status_human
    return SupplyItem::status_to_human(self.status_constant)
  end
  
  # === Named scopes

  scope :available, :conditions => { :status_constant => SupplyItem::AVAILABLE }
  scope :deleted, :conditions => { :status_constant => SupplyItem::DELETED }
  scope :unavailable, :conditions => [ "status_constant <> #{SupplyItem::AVAILABLE}"]
  
  # Thinking Sphinx configuration
  # Must come AFTER associations
  define_index do
    # fields
    indexes name, :sortable => true
    indexes manufacturer, description, supplier_product_code, manufacturer_product_code
    
    # attributes
    has created_at, updated_at
    has supplier_id
    #has suppliers(:id), :as => :supplier_id
    #has suppliers(:id), :as => :supplier_ids
    
    set_property :delta => true

  end
  
  def to_s
    "#{supplier_product_code} #{name}" 
  end
  
  def set_status_to_available_if_nil
    self.status_constant = SupplyItem::AVAILABLE if self.status_constant == nil
  end
  
  def component_of
    product_sets = ProductSet.find_all_by_component_id(self.id)
    product_sets.collect(&:product).uniq
  end
  
  # TODO: Move this method to lib/alltron_util.rb since it is specific
  # to supply items from that supplier.
  def self.new_from_csv_record(csv)
    si = self.new
    si.supplier_product_code = csv['Artikelnummer 2']
    si.name = "#{csv['Bezeichung']} #{csv['Bezeichung 2']}"
    si.manufacturer = "#{csv['Hersteller']}"
    si.product_link = "#{csv['WWW-Link']}"

    si.weight = csv['Gewicht']
    
    si.supplier = Supplier.find_or_create_by_name("Alltron AG")
    si.manufacturer_product_code = csv['Artikelnummer']
    si.description = "#{csv['Webtext']} #{csv['Webtext 2']}"
    si.purchase_price = BigDecimal.new(csv['Preis (exkl. MWSt)'].to_s)
    # TODO: Read actual tax percentage from import file and create class as needed
    si.tax_class = TaxClass.find_by_percentage(8.0) or TaxClass.first
    si.stock = csv['Lagerbestand'].gsub("'","").to_i
    si
  end
  
  def handle_supply_item_deletion
    if self.status_constant_was == SupplyItem::AVAILABLE and \
       self.status_constant == SupplyItem::DELETED
      puts "DELETION OUGHT TO HAPPEN", self.id.to_s, "----_______------___"
      # If this supply item was used as a product component, remove it from the
      # product, disable the product.
      affected_products = self.component_of
      affected_products.each do |ap|
        ap.disable_product
      end
      
      # Disable the product because its supply item has become deleted.
      # This is different from the above, above we handle situations involving
      # _components_ and componentized products
      unless self.product.blank?
        self.product.disable_product
      end
    end
  end
   
end
