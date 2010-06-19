class CreateAdminOrders < ActiveRecord::Migration
  def self.up
    create_table :admin_orders do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :admin_orders
  end
end
