# encoding: utf-8
class IngramTestHelper

  def self.import_from_file(filename)
    require_relative '../../lib/ingram_util'
    iu = IngramUtil.new
    iu.import_supply_items(Rails.root + filename)
  end
  
  def self.update_from_file(filename)
    require_relative '../../lib/ingram_util'
    iu = IngramUtil.new
    iu.update_supply_items(Rails.root + filename)
  end
end
