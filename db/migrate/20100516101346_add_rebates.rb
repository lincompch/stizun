class AddRebates < ActiveRecord::Migration
  def self.up
    add_column :products, :absolute_rebate, :decimal, :default => 0
    add_column :products, :percentage_rebate, :decimal, :default => 0
  end

  def self.down
    remove_column :products, :absolute_rebate
    remove_column :products, :percentage_rebate
  end
end
