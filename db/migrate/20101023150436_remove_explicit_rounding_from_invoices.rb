class RemoveExplicitRoundingFromInvoices < ActiveRecord::Migration
  def self.up
    remove_column :invoice_lines, :rounded_price
    remove_column :invoice_lines, :rounded_single_price
    add_column :invoice_lines, :price, :decimal
    add_column :invoice_lines, :single_price, :decimal

  end

  def self.down
    add_column :invoice_lines, :rounded_price, :decimal
    add_column :invoice_lines, :rounded_single_price, :decimal
    remove_column :invoice_lines, :single_price
    remove_column :invoice_lines, :price

  end
end
