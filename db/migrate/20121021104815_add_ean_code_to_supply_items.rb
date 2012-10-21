class AddEanCodeToSupplyItems < ActiveRecord::Migration
  def change
    add_column :supply_items, :ean_code, :string
  end
end
