class AddShippingTaxesToInvoices < ActiveRecord::Migration
  def self.up
    add_column :invoices, :shipping_taxes, :decimal
  end

  def self.down
    remove_column :invoices, :shipping_taxes
  end
end
