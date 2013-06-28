# encoding: utf-8
class AlltronTestHelper
  require_relative '../../lib/alltron_util'

  def self.import_from_file(filename)
    au = AlltronUtil.new
    au.import_supply_items(Rails.root + filename)
  end

  def self.update_from_file(filename)
    au = AlltronUtil.new
    au.update_supply_items(Rails.root + filename)
  end

  def self.quick_update_stock(filename)
    au = AlltronUtil.new
    au.quick_update_stock(Rails.root + filename)    
  end
  
end
