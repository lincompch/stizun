class SuppliersCategoryTree < ActiveRecord::Migration
  def self.up
    add_column :supply_items, :category_id, :integer
  end

  def self.down
    remove_column :supply_items, :category_id
  end
end
