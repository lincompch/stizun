# encoding: utf-8
class AlltronTestHelper

  def self.import_from_file(filename)
    require_relative '../../lib/alltron_util'
    au = AlltronUtil.new
    au.import_supply_items(Rails.root + filename)
  end
  
  def self.update_from_file(filename)
    require_relative '../../lib/alltron_util'
    au = AlltronUtil.new
    au.update_supply_items(Rails.root + filename)
  end
  
  def self.quick_update_stock(filename)
    require_relative '../../lib/alltron_util'
    au = AlltronUtil.new
    au.quick_update_stock(Rails.root + filename)    
  end
  
end
