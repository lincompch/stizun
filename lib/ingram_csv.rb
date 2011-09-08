# encoding: utf-8

require 'rubygems'
require 'active_record'
require 'ingram_util'

class IngramCSV

  attr_reader :infile
  
  def initialize(import_filename)    
    @infile = import_filename
  end

  def get_csv_instance

    # Setting quote_char to 7.chr (BELL) because that doesn't actually appear in the file, and the file uses no quoting at all, but does
    # use ' sometimes and " a lot, so neither ' nor " can be used as quote_char.
    return @csv ||= CSV.open(@infile, {:col_sep => "\t", :row_sep => "\r\n", :quote_char => 7.chr, :headers => :first_row, :converters => "rb:iso-8859-1:UTF-8"})
    
  end
end
