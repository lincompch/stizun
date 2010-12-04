class InvoiceLinePriceToTaxedPrice < ActiveRecord::Migration
  def self.up
    rename_column :invoice_lines, :price, :taxed_price
  end

  def self.down
    rename_column :invoice_lines, :taxed_price, :price
  end
end
