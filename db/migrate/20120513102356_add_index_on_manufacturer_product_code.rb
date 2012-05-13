class AddIndexOnManufacturerProductCode < ActiveRecord::Migration
  def up
    add_index :products, :manufacturer_product_code
    add_index :supply_items, :manufacturer_product_code
  end

  def down

  end
end
