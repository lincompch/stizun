# encoding: utf-8
class JetTestHelper

  def self.import_from_file(filename)
    require_relative '../../lib/jet_util'
    ju = JetUtil.new
    ju.import_supply_items(Rails.root + filename)
  end
  
  def self.update_from_file(filename)
    require_relative '../../lib/jet_util'
    ju = JetUtil.new
    ju.update_supply_items(Rails.root + filename)
  end
  
  def self.quick_update_stock(filename)
    require_relative '../../lib/jet_util'
    ju = JetUtil.new
    ju.quick_update_stock(Rails.root + filename)    
  end
  
end
