class AddGrossPriceToInvoicesAndInvoiceLines < ActiveRecord::Migration
  def self.up
    add_column :invoice_lines, :gross_price, :decimal, :scale => 30
  end

  def self.down
    remove_column :invoice_lines, :gross_price
  end
end
