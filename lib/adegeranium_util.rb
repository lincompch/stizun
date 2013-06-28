# encoding: utf-8
require 'supplier_util'

class AdegeraniumUtil < SupplierUtil

  def initialize
    @supplier_name = "ADE!Geranium"

    @supplier = Supplier.where(:name => @supplier_name).first
    if @supplier.nil?
      @supplier = Supplier.new
      @supplier.name = @supplier_name
      @supplier.save
    end
    @field_mapping = {:name01 => 1, 
                      :name02 => nil, 
                      :name03 => nil,
                      :description01 => 1, 
                      :description02 => nil, 
                      :supplier_product_code => 0,
                      :price_excluding_vat => 3, 
                      :stock_level => nil, 
                      :manufacturer_product_code => 0, #'Herstellernummer',
                      :manufacturer => nil, #'Hersteller',
                      :weight => nil, #'Gewicht',
                      :pdf_url => nil,
                      :product_link => nil, #'WWW-Link',
                      :category01 => nil, #'Kategorie 1',
                      :category02 => nil, #'Kategorie 2',
                      :category03 => nil, #'Kategorie 3'}
                      :ean_code => nil
                      }

    # Possible options:
    #   :col_sep => the separator character to split() on
    @csv_parse_options = { :col_sep => ";" }
  end

  # Synchronize all supply items from a supplier's provided CSV file
  def import_supply_items(filename)
    super
  end

  def quick_update_stock(filename)
    super
  end

  # Take all the raw data about a supply item and return a nice, meaningful string for its name, which can
  # be different between suppliers and is therefore handled in the supplier-specific subclasses
  def construct_supply_item_name(data)
    # The CSV file contains crazy data, instead of a product name there's a product description several hundred
    # characters long. We just split the word in front of the first comma off of this long text and use that
    # as a name.
    @supply_item_name = "#{data[:name01].split(",")[0]}"
    super
  end

  def construct_supply_item_description(data)
    @description = "#{data[:description01].to_s}"
    @description += " #{data[:description02].to_s}" unless data[:description02].blank?
    super
  end

end
