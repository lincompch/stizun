class RemoveTaxBookerSetting < ActiveRecord::Migration
  def self.up
    ci = ConfigurationItem.where(:key => 'tax_booker_class_name').first
    ci.destroy if ci
  end

  def self.down
  end
end
