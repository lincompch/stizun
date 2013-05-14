# encoding: utf-8
require 'supplier_util'
require 'nokogiri'

class JetUtil < SupplierUtil

  def initialize
  
    @supplier = Supplier.where(:name => 'jET Schweiz IT AG').first
    if @supplier.nil?
      @supplier = Supplier.new
      @supplier.name = "jET Schweiz IT AG"
      @supplier.utility_class_name = "JetUtil"
      @supplier.save
    end
    @field_mapping = {:name01 => 1,
                      :name02 => nil, 
                      :name03 => 11,
                      :description01 => 1, 
                      :description02 => nil, 
                      :supplier_product_code => 0, 
                      :price_excluding_vat => 2, 
                      :stock_level => 9, 
                      :manufacturer_product_code => 11, 
                      :manufacturer => 10, 
                      :weight => 8, 
                      :pdf_url => nil,
                      :description_url => 14,
                      :product_link => nil, 
                      :category01 => 5, 
                      :category02 => 6, 
                      :category03 => nil, 
                      :ean_code => 7 
                      }

    # Possible options:
    #   :col_sep => the separator character to split() on
    @csv_parse_options = { :col_sep => ";", :quote_char => '"' }
    @expected_csv_field_count = 15 # How many fields does a valid line need to have? So we can discard the others
  end

  def self.data_directory
    return Rails.root + "lib"
  end

  def self.import_filename
    return @infile = self.data_directory + "jet.txt"
  end

  # Synchronize all supply items from a supplier's provided CSV file
  def import_supply_items(filename = self.import_filename)
    super
  end



  def self.get_product_description_from_url(url)
    require 'net/http'
    http_logger = Logger.new("#{Rails.root}/log/http_errors.log")
    begin
      res = Net::HTTP.get_response(URI.parse(url))
      case res
      when Net::HTTPSuccess 
        #description = self.sanitize_product_description(res.body.force_encoding("ISO-8859-1").encode("UTF-8")) # When jET change their encoding, you need to change this
        description = self.sanitize_product_description(res.body) # This week, jET seems to use UTF-8. But sometimes they use Latin-1. In all cases, the HTML is invalid and the server headers are not present. Someone should configure that company's server properly and generate some valid HTML...

        # Normalize all headers above level 5 to level 5 -- looks like crap otherwise when used in our pages
        description_html = Nokogiri::HTML(description)
        description_html.xpath("//h1|//h2|//h3|//h4").each do |ele|
          ele.name = "h5"
        end

        return description_html.to_s
      else 
        http_logger.error("Could not retrieve description from #{url}. Response code was: #{res.code}")
        return nil # do nothing!
      end
    rescue Exception => e # For SocketErrors, failed name lookups etc.
      http_logger.error("Could not retrieve description from #{url}. Exception was: #{e.to_s}")
      return nil
    end
  end

  def self.sanitize_product_description(description)
    description = Sanitize.clean(description, Sanitize::Config::STIZUN)
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
