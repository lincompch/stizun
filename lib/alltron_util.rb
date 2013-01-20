# encoding: utf-8
require 'supplier_util'

class AlltronUtil < SupplierUtil

  def initialize
    # The CSV file header looks like this:
    # 0                 1               2           3               4               5           6                  7                     8           9         10          11                  12          13          14              15                  16                17            18             19            20          21          22              23                   24
    # Artikelnummer 2   Artikelnummer   Bezeichung  Bezeichung 2    Lagerbestand    Gewicht    Preis (inkl. MWSt)  Preis (exkl. MWSt)    WWW-Link    Webtext   Webtext 2   Herstellernummer    Hersteller  MWST Satz   Endkundenpreis  Garantie (Monate)   Erfassungsdatum   Kategorie 1   Kategorie 2    Kategorie 3   Kategorie   EAN-Code    Lieferdatum     Ausverkaufsartikel   Discountpreis
    @supplier = Supplier.where(:name => 'Alltron AG').first
    if @supplier.nil?
      @supplier = Supplier.new
      @supplier.name = "Alltron AG"
      @supplier.save
    end
    @field_mapping = {:name01 => 2, # 'Bezeichung',
                      :name02 => 3, #'Bezeichung 2',
                      :name03 => 11,
                      :description01 => 8, #'Webtext',
                      :description02 => 9, #'Webtext 2',
                      :supplier_product_code => 0, #'Artikelnummer 2',
                      :price_excluding_vat => 7, #'Preis (exkl. MWSt)',
                      :stock_level => 4, #'Lagerbestand',
                      :manufacturer_product_code => 11, #'Herstellernummer',
                      :manufacturer => 12, #'Hersteller',
                      :weight => 5, #'Gewicht',
                      :pdf_url => nil,
                      :product_link => 8, #'WWW-Link',
                      :category01 => 17, #'Kategorie 1',
                      :category02 => 18, #'Kategorie 2',
                      :category03 => 19, #'Kategorie 3'}
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

  def quick_update_stock(filename)
    require 'nokogiri'
    stocked_supplier_product_codes = @supplier.supply_items.collect(&:supplier_product_code)
    @updates = []
    doc = Nokogiri::XML(open(filename))
#     binding.pry
    doc.xpath("//item").each do |ele|
      supplier_product_code = ele.children.xpath("../LITM").first.content
      stock = ele.children.xpath("../STQU").first.content
      # Only accept the update if it's something we're stocking
      @updates << [supplier_product_code, stock.to_i] unless (supplier_product_code.blank? or !stocked_supplier_product_codes.include?(supplier_product_code))
    end
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
