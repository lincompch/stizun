require 'supplier_util'

class IngramUtil < SupplierUtil
  
  
  def self.data_directory
    return Rails.root + "lib"
  end
  
  def self.import_filename
    return @infile = self.data_directory + "something.txt"
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
  
    require 'lib/ingram_csv'
    
    IngramUtil.create_shipping_rate
    @supplier = Supplier.find_or_create_by_name(:name => 'Ingram Micro GmbH')
    icsv = IngramCSV.new(filename)
    @fcsv = icsv.get_faster_csv_instance

    @field_names = {:name01 => 'ARTIKEL1',
                    :name02 => '',
                    :description01 => 'ARTIKEL2',
                    :description02 => '',
                    :supplier_product_code => 'ARTIKEL_NR',
                    :price_excluding_vat => 'EK',
                    :stock_level => 'Vmenge',
                    :manufacturer_product_code => 'HSTNUMMER',
                    :manufacturer => 'HERSTELLER',
                    :weight => 'Gewicht',
                    :product_link => 'DATENBLATT1',
                    :image_url => 'BILD1'}    
   
    super
    
  end
  
  
  # Create a default shipping rate for this supplier if it doesn't exist. 
  # This supplier may accidentally not have a matching shipping rate set up,
  # which would ruin shipping calculations. Create a rate with sane defaults
  # if that's the case.
  def self.create_shipping_rate

    
    supplier = Supplier.find_or_create_by_name("Ingram Micro GmbH")
    if supplier.shipping_rate.nil?
      
      tc = TaxClass.find_or_create_by_percentage_and_name(:percentage => 8.0, 
                                                          :name => 'Schweizer Mehrwertsteuer (Normalsatz)') 
      shipping_rate = ShippingRate.new(:name => "Ingram Micro GmbH")  
      shipping_rate.tax_class = tc
      # min_weight, max_weight, price (without VAT)
      costs = [     
                [0, 1000000, 15.60]
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