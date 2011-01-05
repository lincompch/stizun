class AddDefaultFlagToShippingRates < ActiveRecord::Migration
  def self.up
    add_column :shipping_rates, :default, :boolean, :default => false
  end

  def self.down
    remove_column :shipping_rates, :default
  end
end
