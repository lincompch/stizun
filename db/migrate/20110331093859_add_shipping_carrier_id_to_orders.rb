class AddShippingCarrierIdToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :shipping_carrier_id, :integer
  end

  def self.down
    remove_column :orders, :shipping_carrier_id
  end
end
