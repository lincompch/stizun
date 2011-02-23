class AddProductBaseUrlToSupplier < ActiveRecord::Migration
  def self.up
    add_column :suppliers, :product_base_url, :text
  end

  def self.down
    remove_column :suppliers, :product_base_url
  end
end
