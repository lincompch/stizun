# encoding: utf-8
class AdegeraniumTestHelper
  require_relative '../../lib/adegeranium_util'

  def self.import_from_file(filename)
    au = AdegeraniumUtil.new
    au.import_supply_items(Rails.root + filename)
  end
  
  def self.update_from_file(filename)
    au = AdegeraniumUtil.new
    au.update_supply_items(Rails.root + filename)
  end
  
end
