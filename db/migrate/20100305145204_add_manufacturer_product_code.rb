class AddManufacturerProductCode < ActiveRecord::Migration
  def self.up
    add_column :products, :manufacturer_product_code, :string
    add_column :supply_items, :manufacturer_product_code, :string
    
  end

  def self.down
    remove_column :products, :manufacturer_product_code
    remove_column :supply_items, :manufacturer_product_code
        
  end
end
