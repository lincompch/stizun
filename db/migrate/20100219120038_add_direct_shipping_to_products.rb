class AddDirectShippingToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :direct_shipping, :boolean, :default => true
  end

  def self.down
    remove_column :products, :direct_shipping
  end
end
