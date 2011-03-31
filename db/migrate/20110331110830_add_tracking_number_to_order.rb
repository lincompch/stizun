class AddTrackingNumberToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :tracking_number, :string
  end

  def self.down
    remove_column :orders, :tracking_number
  end
end
