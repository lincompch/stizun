class AddOrderStatusConst < ActiveRecord::Migration
  def self.up
    add_column :orders, :status_constant, :integer,  :default => 1
  end

  def self.down
    remove_column :orders, :status_constant
  end
end
