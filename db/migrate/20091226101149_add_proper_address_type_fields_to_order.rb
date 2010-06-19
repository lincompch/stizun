class AddProperAddressTypeFieldsToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :shipping_address_type, :string
    add_column :orders, :billing_address_type, :string
  end

  def self.down
    add_column :orders, :shipping_address_type
    add_column :orders, :billing_address_type
  end
end
