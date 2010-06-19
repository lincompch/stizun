class ReverseLoveStory < ActiveRecord::Migration
  def self.up
    remove_column :orders, :invoice_id
    add_column :invoices, :order_id, :integer
  end

  def self.down
    remove_column :invoices, :order_id
    add_column :orders, :invoice_id, :integer
  end
end