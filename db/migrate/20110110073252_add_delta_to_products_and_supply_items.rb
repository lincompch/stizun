class AddDeltaToProductsAndSupplyItems < ActiveRecord::Migration
  def self.up
    add_column :products, :delta, :boolean, :default => true, :null => false
    add_column :supply_items, :delta, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :products, :delta
    remove_column :supply_items, :delta
  end
end
