require 'supplier_util'

class AlltronUtil < SupplierUtil
  
  
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

  # Synchronize all supply items from a supplier's provided CSV file
  def import_supply_items(filename = self.import_filename)
    
    # Set the variable sources here
  
    require 'lib/alltron_csv'
    # TODO: Create Alltron's very own shipping rate right here, perhaps based ona config file
    AlltronUtil.create_shipping_rate
    @supplier = Supplier.find_or_create_by_name(:name => 'Alltron AG')
    acsv = AlltronCSV.new(filename)
    @fcsv = acsv.get_faster_csv_instance
    
    @field_names = {:name01 => 'Bezeichung',
                    :name02 => 'Bezeichung 2',
                    :name03 => '',
                    :description01 => 'Webtext',
                    :description02 => 'Webtext 2',
                    :supplier_product_code => 'Artikelnummer 2',
                    :price_excluding_vat => 'Preis (exkl. MWSt)',
                    :stock_level => 'Lagerbestand',
                    :manufacturer_product_code => 'Herstellernummer',
                    :manufacturer => 'Hersteller',
                    :weight => 'Gewicht',
                    :pdf_url => '',
                    :product_link => 'WWW-Link',
                    :category01 => 'Kategorie 1',
                    :category02 => 'Kategorie 2',
                    :category03 => 'Kategorie 3'}
    
    super
    
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
