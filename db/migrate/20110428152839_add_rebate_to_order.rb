class AddRebateToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :rebate, :decimal, :precision => 63, :scale => 30, :default => 0.0
  end

  def self.down
    remove_column :orders, :rebate
  end
end
