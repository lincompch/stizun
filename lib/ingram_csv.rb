# encoding: utf-8

require 'rubygems'
require 'active_record'
require 'ingram_util'
require 'supplier_csv'

class IngramCSV < SupplierCSV

  attr_reader :infile
  
  def initialize(import_filename)    
    @infile = import_filename
    super
  end

  def get_csv_instance

    # Setting quote_char to 7.chr (BELL) because that doesn't actually appear in the file, and the file uses no quoting at all, but does
    # use ' sometimes and " a lot, so neither ' nor " can be used as quote_char.
    
    # The file mode "r" prevents Ruby's File::open from dropping into binary-read mode, which would mess up
    # all further handling of the strings read from the CSV file. They would be in ASCII-8BIT, which is
    # useless, we need them in UTF-8.
    return @csv ||= CSV.open(@infile, "r", {:col_sep => "\t", :quote_char => 7.chr, :headers => :first_row})
    
  end
end
