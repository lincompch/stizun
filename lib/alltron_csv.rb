#!/usr/bin/ruby


# The Alltron CSV file has these fields:
# 0                  1               2               3               4               5           6                      7
# Artikelnummer 2    Artikelnummer   Bezeichung      Bezeichung 2    Lagerbestand    Gewicht     Preis (inkl. MWSt)      Preis (exkl. MWSt)
# 
# 8          9           10              11                  12              13          14       
# WWW-Link   Webtext     Webtext 2       Herstellernummer    Hersteller      MWST Satz   Endkundenpreis
# 
# 15                   16                  17              18              19              20
# Garantie (Monate)    Erfassungsdatum     Kategorie 1     Kategorie 2     Kategorie 3     Kategorie
#
# 21              22              23                      24
# EAN-Code        Lieferdatum     Ausverkaufsartikel      Discountpreis

require 'rubygems'
require 'fastercsv'
require 'iconv'
require 'active_record'


class AlltronCSV

  attr_reader :outfile
  attr_reader :class_directory
  
  def initialize
    @class_directory =  File.dirname(__FILE__)
    
    # These path concatenations only work on UNIXoid systems, better use
    # Ruby's built-in platform-neutral directory joining functions in future
    @infile = @class_directory + "/AL_Artikeldaten.txt"
    @outfile = @class_directory + "/AL_Artikeldaten.converted.txt"
    
    convert_file

    #puts "Reading CSV"
    #@products = FasterCSV.read(@outfile, :col_sep => "\t", :headers => :first_row ) if @products.nil?
  end

  def get_faster_csv_instance
    return FasterCSV.new(File.open(@outfile), :col_sep => "\t", :headers => :first_row)
  end
  
  def convert_file
    # Grab the original Alltron file, remove the " characters (FasterCSV does not approve)
    # rewrite as UTF-8

    puts "Trying to convert file"
    if File.exist?(@infile)
      file = File.new(@infile)
      lines = file.readlines
      file.close
    else
      "File #{@infile} not found."
    end

    changes = false
    lines.each do |line|
      line.gsub!(/\"/, " Zoll")
    end

    file = File.new(@outfile,'w')
    lines.each do |line|
      line = Iconv.conv('utf-8', 'iso-8859-1', line)
      file.write(line)
    end
    file.close
  end


  def print_debug(a)
    puts "A0: " + a[0] # model number
    puts "A1: " + a[1]
    puts "A2: " + a[2] # product name
    puts "A3: " + a[3]
    puts "A4: " + a[4] # no. in stock
    puts "A5: " + a[5]
    puts "A6: " + a[6]
    puts "A7: " + a[7] # price
    puts "A8: " + a[8]
    puts "A9: " + a[9]
    puts "A10: " + a[10] unless a[10].blank?
    puts "A11: " + a[11]
    puts "A12: " + a[12]
    puts "A13: " + a[13]
    puts "A14: " + a[14]
    puts "A15: " + a[15]
    puts "A16: " + a[16]
    puts "A17: " + a[17]
    puts "A18: " + a[18]
    puts "A19: " + a[19]
    puts "A20: " + a[20] unless a[20].blank?
    puts "A21: " + a[21] unless a[21].blank?
    puts "A22: " + a[22]
    puts "A23: " + a[23]
    puts "A24: " + a[24]
    puts "A25: " + a[25] unless a[25].blank?
  end

end

