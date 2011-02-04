
class IngramTestHelper

  def self.import_from_file(filename)
    require 'lib/ingram_util'
    IntramUtil.import_supply_items(Rails.root + filename)
  end

end