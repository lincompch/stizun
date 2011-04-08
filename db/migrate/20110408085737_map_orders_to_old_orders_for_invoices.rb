class MapOrdersToOldOrdersForInvoices < ActiveRecord::Migration
  def self.up
    rename_column :invoices, :order_id, :old_order_id
    add_column :invoices, :order_id, :integer
  end

  def self.down
    remove_column :invoices, :order_id
    rename_column :invoices, :old_order_id, :order_id
  end
end
