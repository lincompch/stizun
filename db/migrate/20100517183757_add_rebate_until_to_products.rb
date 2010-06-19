class AddRebateUntilToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :rebate_until, :datetime
  end

  def self.down
    remove_column :products, :rebate_until
  end
end
