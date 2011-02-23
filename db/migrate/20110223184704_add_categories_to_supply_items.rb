class AddCategoriesToSupplyItems < ActiveRecord::Migration
  def self.up
    add_column :supply_items, :category01, :string
    add_column :supply_items, :category02, :string
    add_column :supply_items, :category03, :string
  end

  def self.down
    remove_column :supply_items, :category01
    remove_column :supply_items, :category02
    remove_column :supply_items, :category03
    
  end
end
