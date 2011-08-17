class AddStockAndAvaiableToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :stock, :integer, :default => 0
    add_column :products, :is_available, :boolean, :default => true
  end

  def self.down
    remove_column :products, :stock
    remove_column :products, :is_available
  end
end
