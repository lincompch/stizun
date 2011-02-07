
class AlltronTestHelper

  def self.import_from_file(filename)
    require 'lib/alltron_util'
    au = AlltronUtil.new
    au.import_supply_items(Rails.root + filename)
  end

  def self.encoding
    return "iso-8859-1"
  end
  
end