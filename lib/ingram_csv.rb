
require 'rubygems'
require 'fastercsv'
require 'active_record'
require 'ingram_util'

class IngramCSV

  attr_reader :infile
  
  def initialize(import_filename)    
    @infile = import_filename
  end

  def get_faster_csv_instance
    return @fastercsv ||= FasterCSV.new(File.open(@infile), :col_sep => "\t", :quote_char => "'", :headers => :first_row)
  end
end