class SupplierCSV
  
  def initialize(import_filename = nil)    
    encoding_string = `file -b --mime-encoding #{@infile}`.strip
    if encoding_string != "utf-8"
      raise ArgumentError, "Input file #{@infile} is not encoded in UTF-8. Can only import UTF-8 files."
    end
  end
end