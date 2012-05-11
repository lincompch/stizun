# encoding: utf-8
require 'supplier_util'

class JetUtil < SupplierUtil

  def initialize
  
    @supplier = Supplier.where(:name => 'jET Schweiz IT AG').first
    if @supplier.nil?
      @supplier = Supplier.new
      @supplier.name = "jET Schweiz IT AG"
      @supplier.save
    end
    @field_mapping = {:name01 => 1,
                      :name02 => nil, 
                      :name03 => nil,
                      :description01 => 1, 
                      :description02 => nil, 
                      :supplier_product_code => 0, 
                      :price_excluding_vat => 2, 
                      :stock_level => 9, 
                      :manufacturer_product_code => 11, 
                      :manufacturer => 10, 
                      :weight => 8, 
                      :pdf_url => nil,
                      :product_link => nil, 
                      :category01 => 5, 
                      :category02 => 6, 
                      :category03 => nil, 
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



end
