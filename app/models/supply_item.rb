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
  
  def self.new_from_csv_record(sp)
    si = self.new
    si.supplier_product_code = sp['Artikelnummer 2']
    si.name = "#{sp['Bezeichung']} #{sp['Bezeichung 2']}"
    si.weight = sp['Gewicht']
    si.supplier_id = Supplier.find_by_name("Alltron AG").id
    si.manufacturer_product_code = sp['Artikelnummer']
    si.description = "#{sp['Webtext']} #{sp['Webtext 2']}"
    si.purchase_price = BigDecimal.new(sp['Preis (exkl. MWSt)'].to_s) 
    si.tax_class = TaxClass.find_by_percentage(7.6) or TaxClass.first
    si.stock = sp['Lagerbestand'].gsub("'","").to_i
    si
  end
  
  # Synchronize all supply items from a supplier's provided CSV file
  # Currently only one supplier is supported. This is enough for the
  # prototype developed as part of the dissertation, but in the final
  # product this needs to be modular and allow each supplier to provide
  # either files or an API to synchronize from.
  def self.synchronize
    require 'lib/alltron_csv'
    acsv = AlltronCSV.new
    fcsv = acsv.get_faster_csv_instance
    received_codes = []
    fcsv.each do |sp|
      # Keep track of which products we received, so we can later determine which ones
      # we are stocking but shouldn't be stocking anymore
      received_codes << sp['Artikelnummer 2']
      # check if we have product too
      local_supply_item = SupplyItem.find_by_supplier_product_code(sp['Artikelnummer 2'])
      
      # We do not have that supply item yet
      if local_supply_item.nil?
        si= SupplyItem.new_from_csv_record(sp)
        
        if si.save
          History.add("Supply item added during sync: #{si.to_s}", History::SUPPLY_ITEM_CHANGE, si)
        else
          History.add("Failed adding supply item during sync: #{si.inspect.to_s}, #{si.errors.to_s}", History::SUPPLY_ITEM_CHANGE, si)
        end
      
      # We already have that supply item and need to update supply item
      # and related product information
      else
        if local_supply_item.purchase_price != BigDecimal(sp['Preis (exkl. MWSt)'].to_s)
          old_price = local_supply_item.purchase_price
          local_supply_item.purchase_price = BigDecimal(sp['Preis (exkl. MWSt)'].to_s)
          local_supply_item.save
          History.add("Changed price for #{local_supply_item.to_s} from #{old_price} to #{local_supply_item.purchase_price}", History::SUPPLY_ITEM_CHANGE, local_supply_item)
        end
        
        if local_supply_item.stock != sp['Lagerbestand'].gsub("'","").to_i
          old_stock = local_supply_item.stock
          local_supply_item.stock = sp['Lagerbestand'].gsub("'","").to_i
          local_supply_item.save
          History.add("Changed stock for #{local_supply_item.to_s} from #{old_stock} to #{local_supply_item.stock}", History::SUPPLY_ITEM_CHANGE, local_supply_item)
        end
      end
    end

    # Find out which items we need to delete locally
    total_codes = SupplyItem.find(:all, :conditions => { :supplier_id => 1 }).collect(&:supplier_product_code)
    to_delete = total_codes - received_codes
    
    # And delete them -- delete_all is much more efficient than destroy_all
    SupplyItem.delete_all(:supplier_product_code => to_delete) unless to_delete.blank? # the .blank? check prevents it from deleting everything if to_delete is empty.
    to_delete.each do |td|
      # TODO: Find all products that have this supply item as component. Make sure to remove
      # these components, disable the componentized product and notify admin somehow about the changes
      
      affected_products = td.component_of
      affected_products.each do |ap|
        # Tries to brute force removing all counts of this component by hardcoding
        # 99999999 as component count. TODO: Count components, do this properly, or add
        # a remove_components method to Product
        ap.remove_component(td, 99999999)
        ap.is_available = false
        ap.save
        History.add("Component #{td} was removed from product #{ap} because it has become unavailable.", History::PRODUCT_CHANGE, ap)
      end
      History.add_text("Deleted Supply Item with supplier code #{td}", History::SUPPLY_ITEM_CHANGE)
    end
    
  end
end
