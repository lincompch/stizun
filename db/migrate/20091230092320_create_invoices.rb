class CreateInvoices < ActiveRecord::Migration
  def self.up
    create_table :invoices do |t|
      t.integer :shipping_address_id
      t.string :shipping_address_type
      t.integer :billing_address_id
      t.string :billing_address_type
      t.integer :user_id
      t.integer :status_constant, :default => 1

      t.timestamps
    end
  end

  def self.down
    drop_table :invoices
  end
end
