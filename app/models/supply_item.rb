class SupplyItem < ActiveRecord::Base
  
  belongs_to :tax_class
  belongs_to :supplier
  has_one :product
  
  
  
  def self.per_page
    return 100
  end
  
  # Thinking Sphinx configuration
  # Must come AFTER associations
  define_index do
    # fields
    indexes name, :sortable => true
    indexes description, supplier_product_code, manufacturer_product_code
    
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
  


   
end
