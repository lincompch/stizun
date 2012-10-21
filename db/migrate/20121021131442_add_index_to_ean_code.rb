class AddIndexToEanCode < ActiveRecord::Migration
  def change
    add_index :products, :ean_code, :length => 15
    add_index :supply_items, :ean_code, :length => 15
  end
end
