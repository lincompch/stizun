# encoding: utf-8
class Alltron2013TestHelper
  require_relative '../../lib/alltron_util'

  def self.import_from_file(filename)
    au = Alltron2013Util.new
    au.import_supply_items(Rails.root + filename)
  end

  def self.update_from_file(filename)
    au = Alltron2013Util.new
    au.update_supply_items(Rails.root + filename)
  end

  def self.quick_update_stock(filename)
    au = Alltron2013Util.new
    au.quick_update_stock(Rails.root + filename)    
  end
  
end
