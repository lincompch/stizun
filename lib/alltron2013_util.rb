# encoding: utf-8
require 'supplier_util'

class Alltron2013Util < SupplierUtil

  def initialize
    @supplier = Supplier.where(:name => 'Alltron AG').first
    if @supplier.nil?
      @supplier = Supplier.new
      @supplier.name = "Alltron AG"
      @supplier.save
    end
    @field_mapping = {:name01 => 2,
                      :name02 => 3,
                      :name03 => 11,
                      :description01 => 9,
                      :description02 => 10,
                      :supplier_product_code => 0,
                      :price_excluding_vat => 7,
                      :stock_level => 4,
                      :manufacturer_product_code => 11,
                      :manufacturer => 12,
                      :weight => 5,
                      :pdf_url => nil,
                      :product_link => 8,
                      :category01 => 17,
                      :category02 => 18,
                      :category03 => 19,
                      :ean_code => 21
                      }

    # Possible options:
    #   :col_sep => the separator character to split() on
    @csv_parse_options = { :col_sep => "\t" }
  end

  def self.data_directory
    return Rails.root + "lib"
  end

  def self.import_filename
    return @infile = self.data_directory + "AL_Artikeldaten.txt"
  end

  # Synchronize all supply items from a supplier's provided CSV file
  def import_supply_items(filename = self.import_filename)
    super
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
