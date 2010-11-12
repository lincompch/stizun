class SupplyItem < ActiveRecord::Base
  
  belongs_to :tax_class
  belongs_to :supplier
  has_one :product
  
  def to_s
    "#{supplier_product_code} #{name}" 
  end
  
  def component_of
    product_sets = ProductSet.find_all_by_component_id(self.id)
    product_sets.collect(&:product).uniq
  end
  
  # TODO: Move this method to lib/alltron_util.rb since it is specific
  # to supply items from this supplier.
  def self.new_from_csv_record(sp)
    si = self.new
    si.supplier_product_code = sp['Artikelnummer 2']
    si.name = "#{sp['Bezeichung']} #{sp['Bezeichung 2']}"
    si.weight = sp['Gewicht']
    si.supplier = Supplier.find_or_create_by_name("Alltron AG")
    si.manufacturer_product_code = sp['Artikelnummer']
    si.description = "#{sp['Webtext']} #{sp['Webtext 2']}"
    si.purchase_price = BigDecimal.new(sp['Preis (exkl. MWSt)'].to_s)
    # TODO: Read actual tax percentage from import file and create class as needed
    si.tax_class = TaxClass.find_by_percentage(7.6) or TaxClass.first
    si.stock = sp['Lagerbestand'].gsub("'","").to_i
    si
  end
  


   
end
