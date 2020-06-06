# encoding: utf-8
require 'supplier_util'

class IngramUtil < SupplierUtil

    def initialize
    # The CSV file header looks like this:
    # 0         1        2       3           4           5           6           7           8           9       10          11      12      13          14  15  16          17      18      19              20      21      22      23          24          25      26      27      28      29      30      31      32      33      34          35          36      37      38      39          40          41
    # GRUPPE1   GRUPPE2  GRUPPE3 HERSTELLER  ARTIKEL_NR  HSTNUMMER   ARTIKEL1    ARTIKEL2    FVERSION    FSYSTEM FSPRACHE    FFORMAT FBUS    FGARANTIE   EVP EK  AKTIONPR    AKTBIS  AKTION  VerfuegbarKZ    Vmenge  VDatum  VEta    Nachfolger  DATENBLATT1 BILD1   ERFDAT  EANCode UPCCode Hoehe   Breite  Laenge  Gewicht Rang    Stck_Kart   Stck_Pal    Storno  ECLass  UNSPC   INTRASTAT   CatalogID   Auslieferungslager

    @supplier = Supplier.where(:name => 'Ingram Micro GmbH').first
    if @supplier.nil?
      @supplier = Supplier.new
      @supplier.name = "Ingram Micro GmbH"
      @supplier.save
    end

    @field_mapping = {:name01 => 2, #'HERSTELLER',
                      :name02 => 6, #'ARTIKEL1',
                      :name03 => 5, #'HSTNUMMER',
                      :description01 => 7, #'ARTIKEL2',
                      :description02 => nil,
                      :supplier_product_code => 3, #'ARTIKEL_NR',
                      :price_excluding_vat => 15, #'EK',
                      :stock_level => 20, #'Vmenge',
                      :manufacturer_product_code => 5, #'HSTNUMMER',
                      :manufacturer => 2, #'HERSTELLER',
                      :weight => 34, #'Gewicht',
                      :product_link => nil,
                      :pdf_url => 26, #'DATENBLATT1',
                      :image_url => 27, #'BILD1',
                      :category01 => 0, #'GRUPPE1',
                      :category02 => 1, #'GRUPPE2',
                      :category03 => nil,
                      :ean_code => 29
                      }

    # Possible options:
    #   :col_sep => the separator character to split() on
    @csv_parse_options = { :col_sep => "|" }
  end

  def self.data_directory
    return Rails.root + "lib"
  end

  def self.import_filename
    return @infile = self.data_directory + "something.txt"
  end

  # Synchronize all supply items from a supplier's provided CSV file
  def import_supply_items(filename = self.import_filename)
    super
  end

  def self.request_update(product_code, customer_no, password)
    require 'net/https'
    logger = Logger.new("#{Rails.root}/log/ingram_live_update_#{Time.now.strftime("%Y-%m-%d")}.log")

    username = "CH" + customer_no + "XM"

    host = "newport.ingrammicro.com"
    port = 443
    path = "/imxml"
    begin
      http = Net::HTTP.new(host, port)
      http.use_ssl = true
      http.start do |h|
        xmlreq = "<PNARequest>
          <Version>2.0</Version>
          <TransactionHeader>
            <SenderID>123456789</SenderID>
            <ReceiverID>987654321</ReceiverID>
            <CountryCode>CH</CountryCode>
            <LoginID>#{username}</LoginID>
            <Password>#{password}</Password>
            <TransactionID>54321</TransactionID>
          </TransactionHeader>
          <PNAInformation SKU=\"#{product_code}\" ManufacturerPartNumber=\"\" Quantity=\"1\"
          ReservedInventory =\"Y\"/>
          <ShowDetail>1</ShowDetail>
        </PNARequest>"

        req = Net::HTTP::Post.new(path)
        req.body = xmlreq
        req.content_type = 'text/xml'
        logger.info "[#{DateTime.now.to_s}] Sending request to path: #{path}"
        response = h.request(req)


        if response.code == "200"
          #logger.info "[#{DateTime.now.to_s}] Response body: #{response.body.split("\n").join("|")}"
          xml = Nokogiri::XML(response.body)

          if xml.at_css("ErrorStatus").text != ""
            logger.error "#{xml.at_css('ErrorStatus').text}"
            return {}
          end

          price = xml.at_css("Price").text.sub(',', '.').to_f
          stock = xml.at_css("Availability").text.to_i

          if price.to_i == 0
            logger.info "[#{DateTime.now.to_s}] Live update for product with supplier product code #{product_code} would have set our price to 0.0. Skipping this product."
            return {}
          end

          product = Product.where(:supplier_product_code => product_code).first

          # Skip if the product already had an update less than 30 minutes ago, and assign
          # a reasonably early date if it is nil
          product.auto_updated_at = DateTime.parse("1900-01-01") if product.auto_updated_at.nil?
          return {} if (DateTime.now - 30.minutes) < product.auto_updated_at

          old_price = product.taxed_price.rounded
          new_purchase_price = BigDecimal.new(price.to_s)
          product.purchase_price = new_purchase_price
          product.stock = stock

          if product.changes.empty?
            logger.info "[#{DateTime.now.to_s}] Live update for #{product} was triggered, but there were no changes."
          else
            changes = product.changes.clone
            product.auto_updated_at = DateTime.now
            if product.save
              changes.merge!({ "product_id" => product.id })
              changes.merge!({ "price" => [old_price, product.taxed_price.rounded] }) unless changes['purchase_price'].blank?
              changes.delete('auto_updated_at') # We're not interested in this, since it might happen that this is the only value that changed, and that's not very interesting
              logger.info "[#{DateTime.now.to_s}] Live update for #{product} was triggered, changes: #{changes.inspect}"
            else
              logger.error "[#{DateTime.now.to_s}] Live update for #{product} was triggered, but there was an error saving them: #{product.errors.full_messages}"
            end
          end

          return changes

        else
          logger.error "[#{DateTime.now.to_s}] Non-OK response. Response body: #{response.body.split("\n").join("|")}"
          return {}
        end
      end

    rescue Exception => e
      logger.error "[#{DateTime.now.to_s}] Exception during Ingram Micro HTTPS document lines/product live update"
      logger.error e.message
      logger.error e.backtrace.inspect
      # A blank array indicates that nothing useful happened
      return {}
    end
  end


  # Update a product's information (stock level, price) from Ingram Micro's live update URL
  # Input: DocumentLines object if multiple products need to be updated (e.g. from a Cart object)
  # Input: Product object if just a single object needs to be updated
  # Output: A hash with the product ID as an index, pointing to a hash of arrays of changes with
  #         the changed attribute as an index (similar to ActiveRecord changes)
  def self.live_update(object)
    # Can't work without these two
    if (APP_CONFIG['ingram_customer_number'].blank? or APP_CONFIG['ingram_password'].blank?)
      return []
    end

    customer_no = APP_CONFIG['ingram_customer_number']
    password = APP_CONFIG['ingram_password']

    if customer_no.empty? or password.empty?
      logger.error "[#{DateTime.now.to_s}] Live update will probably fail, either username or password are not set"
    end

    if object.is_a?(Product)
      products = [object]
    elsif object.is_a?(Array)
      products = object.collect(&:product)
    else
      raise ArgumentError, "This method can only deal with Product objects or arrays of DocumentLines"
    end

    changed = []
    products.each do |p|
      changes = request_update(p.supplier_product_code, customer_no, password)
      if changes
        #changed[p.id] = changes
        changed << changes
      end
    end
    changed
  end


  # Take all the raw data about a supply item and return a nice, meaningful string for its name, which can
  # be different between suppliers and is therefore handled in the supplier-specific subclasses
  def construct_supply_item_name(data)
    @supply_item_name = "#{data[:name01]}"
    @supply_item_name += " #{data[:name02]}" unless data[:name02].blank?
    @supply_item_name += " (#{data[:name03]})" unless data[:name03].blank?
    super
  end

  def construct_supply_item_description(data)
    @description = "#{data[:description01].to_s}"
    @description += " #{data[:description02].to_s}" unless data[:description02].blank?
    super
  end
end
