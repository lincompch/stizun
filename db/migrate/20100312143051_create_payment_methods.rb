class CreatePaymentMethods < ActiveRecord::Migration
  def self.up
    create_table :payment_methods do |t|
      t.string :name
      t.boolean :allows_direct_shipping
      t.timestamps
    end
    create_table :payment_methods_users, :id => false do |t|
      t.integer :payment_method_id
      t.integer :user_id
    end
    add_column :invoices, :payment_method_id, :integer
    add_column :orders, :payment_method_id, :integer
  end

  def self.down
    drop_table :payment_methods
    drop_table :payment_methods_users
    remove_column :invoices, :payment_method_id
    remove_column :orders, :payment_method_id
  end
end
