class AddShippingTaxesToInvoices < ActiveRecord::Migration
  def self.up
    add_column :invoices, :shipping_taxes, :decimal, :scale => 30, :precision => 63
  end

  def self.down
    remove_column :invoices, :shipping_taxes
  end
end
