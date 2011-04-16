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

    @field_names = {:name01 => 'HERSTELLER',
                    :name02 => 'ARTIKEL1',
                    :name03 => 'HSTNUMMER',
                    :description01 => 'ARTIKEL2',
                    :description02 => '',
                    :supplier_product_code => 'ARTIKEL_NR',
                    :price_excluding_vat => 'EK',
                    :stock_level => 'Vmenge',
                    :manufacturer_product_code => 'HSTNUMMER',
                    :manufacturer => 'HERSTELLER',
                    :weight => 'Gewicht',
                    :product_link => '',
                    :pdf_url => 'DATENBLATT1',
                    :image_url => 'BILD1',
                    :category01 => 'GRUPPE1',
                    :category02 => 'GRUPPE2',
                    :category03 => 'GRUPPE3'}    
   
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


  # Update a product's information (stock level, price) from Ingram Micro's live update URL
  # Input: DocumentLines
  # Output: A hash with the product ID as an index, pointing to a hash of arrays of changes with
  #         the changed attribute as an index (similar to ActiveRecord changes)
  def self.live_update(lines)

    logger = Logger.new("#{Rails.root}/log/ingram_live_update_#{Time.now.strftime("%Y-%m-%d")}.log")
    
    # e.g. from Ingram Micro GmbH:
    # http://CH27KNR000@www.ingrammicro.de/cgi-bin/scripts/get_avail.pl?CCD=CH&BNR=27&KNR=999999&SKU=016Z006~016Z007&QTY=10~100&SYS=CF
    #
    # KNR: ihre Kundennummer z.B. CH27620030000
    # PWD: ihr Passwort für die INGRAM MICRO Online Systeme (IM.Order)
    # CCD: CompanyCode "CH" für die Schweiz
    # KNR: ihre sechsstellige Kundennummer
    # BNR: BranchNbr  (27)
    # SKU: INGRAM MICRO Artikelnummer mit ~ getrennt können auch mehrere Artikelnummern übergeben werden
    # HST: Alternativ zur INGRAM MICRO Artikelnummer kann auch die Hersteller Artikelnummer übergeben werden. Auch hier können mehrere Artikel mit ~ getrennt übergeben werden.
    # QTY: gewünschte Menge für jeden Artikel mit ~ getrennt (optional, Standard=1)
    # SYS: steuert den Response. Mögliche Parameter sind CF, CF_QTY und XML.
    #
    # Response:
    # SYS=CF     Artikelnummer;Lagerbestand;Preis in Schweizer Rappen;Zeit;Liefertermin;
    # SYS=CF_QTY      Lagerbestand
    # SYS=XML

    customer_no = APP_CONFIG['ingram_customer_number']
    username = "CH27" + customer_no + "000"
    password = APP_CONFIG['ingram_password']
    
    products = lines.collect(&:product)
    supplier_product_codes = products.collect(&:supplier_product_code)
    supplier_product_code_string = supplier_product_codes.join("~")
    quantities = (["1"] * supplier_product_codes.size).join("~")
    
    require 'net/https'

    host = "www.ingrammicro.de"
    port = 443
    path = "/cgi-bin/scripts/get_avail.pl?CCD=CH&BNR=27&KNR=#{customer_no}&SKU=#{supplier_product_code_string}&QTY=#{quantities}&SYS=CF"

    puts "trying #{path}"
    
    begin
      http = Net::HTTP.new(host, 443)
      http.use_ssl = true
      http.start do |http|
        req = Net::HTTP::Get.new(path)
        req.basic_auth(username, password)
        response = http.request(req)

        if response.code == "200"
          puts "body is: #{response.body}"
          
          update_lines = response.body.split("\n")
          update_lines.each do |line|
            product_code, stock, price_in_cents, time, delivery_date = line.split(";")
            product = Product.where(:supplier_product_code => product_code).first
            old_price = product.taxed_price.rounded
            new_purchase_price = BigDecimal.new( (price_in_cents.to_i / 100.0).to_s )
            new_stock = stock
            product.purchase_price = new_purchase_price
            product.stock = stock
            
            if product.changes.empty?
                            puts "[#{DateTime.now.to_s}] Live update for #{product} was triggered, but there were no changes."

              logger.info "[#{DateTime.now.to_s}] Live update for #{product} was triggered, but there were no changes."
              #return nil
            else
              changes = product.changes.clone
              if true # product.save
                changes.merge!({ "price" => [old_price, product.taxed_price.rounded] }) unless changes['purchase_price'].blank?
                puts "[#{DateTime.now.to_s}] Live update for #{product} was triggered, changes: #{changes.inspect}"
                logger.info "[#{DateTime.now.to_s}] Live update for #{product} was triggered, changes: #{changes.inspect}"
              else
                logger.error "[#{DateTime.now.to_s}] Live update for #{product} was triggered, but there was an error saving them: #{product.errors.full_messages}"
              end
              #return changes
            end                  
            
          end
                    


        end
      end

    rescue Exception => e
      logger.error "[#{DateTime.now.to_s}] Exception during Ingram Micro HTTPS product update for #{product}"
      logger.error e.message
      logger.error e.backtrace.inspect
    end

  end


  
end