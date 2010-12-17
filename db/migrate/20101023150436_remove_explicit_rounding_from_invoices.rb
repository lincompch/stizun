class RemoveExplicitRoundingFromInvoices < ActiveRecord::Migration
  def self.up
    remove_column :invoice_lines, :rounded_price
    add_column :invoice_lines, :price, :decimal, :scale => 30, :precision => 63
    add_column :invoice_lines, :single_price, :decimal, :scale => 30, :precision => 63

  end

  def self.down
    add_column :invoice_lines, :rounded_price, :decimal, :scale => 30, :precision => 63
    remove_column :invoice_lines, :single_price
    remove_column :invoice_lines, :price

  end
end
