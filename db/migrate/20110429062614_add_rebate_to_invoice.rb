class AddRebateToInvoice < ActiveRecord::Migration
  def self.up
    add_column :invoices, :rebate, :decimal, :precision => 63, :scale => 30, :default => 0.0
  end

  def self.down
    remove_column :invoices, :rebate
  end
end
