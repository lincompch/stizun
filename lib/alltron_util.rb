class AlltronUtil
  
  
  def self.data_directory
    return Rails.root + "lib"
  end
  
  # This just sets a default import filename inside AlltronCSV in case the call to
  # AlltronCSV.new doesn't pass one in.
  def self.import_filename
    return @infile = self.data_directory + "AL_Artikeldaten.txt"
  end
  
  
  # This makes sure the converted import filename is always overwritten with
  # importfile.converted.txt. A more sophisticated way might be necessary one day.
  def self.converted_filename
    return @outfile = self.data_directory + "importfile.converted.txt"
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

  def self.disable_product(product)
    product.is_available = false
    if product.save
      History.add("Disabled product #{product.to_s}.", History::PRODUCT_CHANGE, product)
    else
      History.add("Could not disable product #{product.to_s}.", History::PRODUCT_CHANGE, product)
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
        self.disable_product(p)
        History.add("Disabled product #{p.to_s} because its supply item is gone.", History::PRODUCT_CHANGE,  p)
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
  def self.import_supply_items(filename = self.import_filename)
    require 'lib/alltron_csv'
    # TODO: Create Alltron's very own shipping rate right here, perhaps based ona config file
    self.create_shipping_rate
    supplier = Supplier.find_or_create_by_name(:name => 'Alltron AG')
    acsv = AlltronCSV.new(filename)
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
    total_codes = supplier \
                   .supply_items \
                   .collect(&:supplier_product_code)
    to_delete = total_codes - received_codes
        
    to_delete.each do |td|
      supply_item = SupplyItem.find_by_supplier_product_code(td)
      
      # If this supply item was used as a product component, remove it from the
      # product, disable the product.
      affected_products = supply_item.component_of
      affected_products.each do |ap|
        # Tries to brute force removing all counts of this component by hardcoding
        # 99999999 as component count. TODO: Count components, do this properly, or add
        # a remove_components method to Product
        ap.remove_component(td, 99999999)
        ap.is_available = false
        ap.save
        History.add("Component #{td} was removed from product #{ap} because the supply item has become unavailable.", History::PRODUCT_CHANGE, ap)
        # Just adding text here because the supply_item object will soon no longer exist
        History.add("Component #{td} was removed from product #{ap} because the supply item has become unavailable.", History::SUPPLY_ITEM_CHANGE)
      end
      
      # Destroy the supply item relationship in case a product was based on it. 
      # This is different to above, above we only disable parts used as _components_
      unless supply_item.product.blank?
        supply_item.product.supply_item = nil
        self.disable_product(supply_item.product)
        if supply_item.product.save
          History.add("Disassociated Supply Item with ID #{supply_item.id} (#{supply_item.to_s}) from its product because it's about to be destroyed.", History::SUPPLY_ITEM_CHANGE)
        else
          History.add("Failed to disassociate Supply Item with ID #{supply_item.id} (#{supply_item.to_s}) from its product, but it's about to be destroyed anyhow. Errors: #{supply_item.product.errors.full_messages.to_s}", History::SUPPLY_ITEM_CHANGE)
        end
      end
      supply_item.destroy
      History.add("Deleted Supply Item with supplier code #{td}", History::SUPPLY_ITEM_CHANGE)
    end
    
  end
  
  
  # Create a default shipping rate for this supplier if it doesn't exist. 
  # This supplier may accidentally not have a matching shipping rate set up,
  # which would ruin shipping calculations. Create a rate with sane defaults
  # if that's the case.
  def self.create_shipping_rate
      
    # Post    
    # Post Pac Priority   Preis in CHF (exkl. MwSt)
    # Grundtaxe   8.00
    # pro Kilo    + 0.65
    # Stückgut via Setz   
    # Volumen   Preis in CHF (exkl. MwSt)
    # Colis 30 - 100 kg   58.60
    # 1 Palette   69.70
    # 2 Paletten    139.50
    # 3 Paletten    209.10
    # 4 Paletten    278.80
    # 5 Paletten    348.51
    # Sonderleistungen    
    # Leistung    Preis in CHF (exkl. MwSt)
    # Direktlieferung an einen Endkunden    + 4.70
    # Express-Lieferung per Post    + 14.00
    # Nachnahme   + 14.00
    # Express-Lieferung durch Setz    nach Aufwand
    # Lieferung durch Kurierdienst    nach Aufwand
    
    supplier = Supplier.find_or_create_by_name("Alltron AG")
    if supplier.shipping_rate.nil?
      
      tc = TaxClass.find_or_create_by_percentage_and_name(:percentage => 8.0, 
                                                          :name => 'Schweizer Mehrwertsteuer (Normalsatz)') 
      shipping_rate = ShippingRate.new(:name => "Alltron AG")  
      shipping_rate.tax_class = tc
      # min_weight, max_weight, price (without VAT)
      costs = [     
                [0, 1000, 8.65],
                [1001, 2000, 9.3],
                [2001, 3000, 9.95],
                [3001, 4000, 10.6],
                [4001, 5000, 11.25],
                [5001, 6000, 11.9],
                [6001, 7000, 12.55],
                [7001, 8000, 13.2],
                [8001, 9000, 13.85],
                [9001, 10000, 14.5],
                [10001, 11000, 15.15],
                [11001, 12000, 15.8],
                [12001, 13000, 16.45],
                [13001, 14000, 17.1],
                [14001, 15000, 17.75],
                [15001, 16000, 18.4],
                [16001, 17000, 19.05],
                [17001, 18000, 19.7],
                [18001, 19000, 20.35],
                [19001, 20000, 21.0],
                [20001, 21000, 21.65],
                [21001, 22000, 22.3],
                [22001, 23000, 22.95],
                [23001, 24000, 23.6],
                [24001, 25000, 24.25],
                [25001, 26000, 24.9],
                [26001, 27000, 25.55],
                [27001, 28000, 26.2],
                [28001, 29000, 26.85],
                [29001, 30000, 27.5],
                [30001, 100000, 58.60]
              ]
      costs.each do |c|    
        shipping_rate.shipping_costs << ShippingCost.new(:weight_min => c[0], 
                                                         :weight_max => c[1], 
                                                         :price => c[2], 
                                                         :tax_class => tc)
      end
      shipping_rate.save     
      supplier.shipping_rate = shipping_rate
      supplier.save
      return shipping_rate
    end
    return supplier.shipping_rate
  end
  
end
