#!/usr/bin/ruby

class AlltronUtil
  
  def self.import_filename
    # Stupid place to store it? Yeah, you tell me.
    class_directory =  File.dirname(__FILE__)
    return @infile = class_directory + "/AL_Artikeldaten.txt"
  end
  
  def self.converted_filename
    class_directory =  File.dirname(__FILE__)
    return @outfile = class_directory + "/AL_Artikeldaten.converted.txt"
  end
      
  
  # Processes the AL_Artikeldaten.txt CSV file to extract
  # all unique combinations of categories, then builds this category
  # tree in the system as belonging to Alltron as supplier.
  #
  # Uses cut, sort and uniq from the shell to reduce the main extraction task 
  # to 300 milliseconds on a reasonably fast system.
  def self.build_category_tree
    
    if File.exist?(self.converted_filename)      
      # The resulting string is in this format:
      # Category 1\tCategory 2\tCategory 3\n
      # Category 1\tCategory 6\tCategory 12\n
      # etc.      
      category_string = `cut -f 18-20 #{self.converted_filename} | sort -n | uniq`

      category_string.split("\n").each do |line|
        categories = line.split("\t")
        puts categories.inspect
        
        # TODO: Make sure categories always know their place in the tree, even if
        # lower-level branches have the same name as higher-level ones
        
        # Find or create the root category
        root = Category.find_or_create_by_name(categories[0])
        root.save
        
        # Find or create level 2 category and assign it to root as parent
        level2 = Category.find_or_create_by_name(categories[1])
        level2.parent = root
        level2.save
        
        unless categories[2].blank?
          # Find or create level 3 category and assign it to level 2 category as parent
          level3 = Category.find_or_create_by_name(categories[2])
          level3.parent = level2
          level3.save
        end        
      end
      
    else
      return false
    end
    
  end

  # Compare all products that are related to a supply item with
  # the supply item's current stock level and price. Make adjustments
  # as necessary.
  def self.update_price_and_stock
    
    Product.supplied.each do |p|
      # The supply item is no longer available, thus we need to
      # make our own copy of it unavailable as well
      
      # The product has a supplier, but its supply item is gone
      if p.supply_item.nil? and !p.supplier_id.blank?
        p.is_available = false
        p.save
        History.add("Disabled product #{p.to_s} because it is no longer available at supplier.", History::PRODUCT_CHANGE, p)
      else
        # Disabling product because we would be incurring a loss otherwise
        if (p.absolutely_priced? and p.supply_item.purchase_price > p.sales_price)
          p.is_available = false
          p.save
          History.add("Disabled product #{p.to_s} because purchase price is higher than absolute sales price.", History::PRODUCT_CHANGE,  p)
          
        # Nothing special to do to this product -- just update price and stock
        else
          old_stock = p.stock
          old_price = p.purchase_price.to_s
          p.stock = p.supply_item.stock
          p.purchase_price = p.supply_item.purchase_price
          p.save
          History.add("Product update: #{p.to_s} price from #{old_price} to #{p.purchase_price}, stock from #{old_stock} to #{p.stock}", History::PRODUCT_CHANGE, p)
        end
      end
    end    
  end

  # Synchronize all supply items from a supplier's provided CSV file
  # Currently only one supplier is supported. This is enough for the
  # prototype developed as part of the dissertation, but in the final
  # product this needs to be modular and allow each supplier to provide
  # either files or an API to synchronize from.
  def self.import_supply_items
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
    
    to_delete.each do |td|
      supply_item = SupplyItem.find_by_supplier_product_code(td)
      affected_products = supply_item.component_of
      affected_products.each do |ap|
        # Tries to brute force removing all counts of this component by hardcoding
        # 99999999 as component count. TODO: Count components, do this properly, or add
        # a remove_components method to Product
        ap.remove_component(td, 99999999)
        ap.is_available = false
        ap.save
        History.add("Component #{td} was removed from product #{ap} because it has become unavailable.", History::PRODUCT_CHANGE, ap)
      end
      supply_item.destroy
      History.add_text("Deleted Supply Item with supplier code #{td}", History::SUPPLY_ITEM_CHANGE)
    end
    
  end
  
end