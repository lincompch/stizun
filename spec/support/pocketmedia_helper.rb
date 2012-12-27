# encoding: utf-8
class PocketmediaTestHelper

  def self.import_from_file(filename)
    require_relative '../../lib/pocketmedia_util'
    au = PocketmediaUtil.new
    au.import_supply_items(Rails.root + filename)
  end
  
  def self.update_from_file(filename)
    require_relative '../../lib/pocketmedia_util'
    au = PocketmediaUtil.new
    au.update_supply_items(Rails.root + filename)
  end
  
  def self.quick_update_stock(filename)
    require_relative '../../lib/pocketmedia_util'
    au = PocketmediaUtil.new
    au.quick_update_stock(Rails.root + filename)    
  end
  
end
