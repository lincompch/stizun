class AddManufacturerAndProductLink < ActiveRecord::Migration
  def self.up
    add_column :supply_items, :manufacturer, :string
    add_column :supply_items, :product_link, :string
    add_column :products, :manufacturer, :string
    add_column :products, :product_link, :string
    
  end

  def self.down
    remove_column :supply_items, :manufacturer
    remove_column :supply_items, :product_link
    remove_column :products, :manufacturer
    remove_column :products, :product_link
  end
end
