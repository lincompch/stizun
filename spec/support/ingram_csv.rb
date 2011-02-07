
class IngramTestHelper

  def self.import_from_file(filename)
    require 'lib/ingram_util'
    iu = IngramUtil.new
    iu.import_supply_items(Rails.root + filename)
  end
  
  def self.encoding
    return "iso-8859-1"
  end

end