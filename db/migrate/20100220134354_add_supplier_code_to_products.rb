class AddSupplierCodeToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :supplier_product_code, :string
  end

  def self.down
    remove_column :products, :supplier_product_code
  end
end
