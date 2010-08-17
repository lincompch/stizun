class AddGrossPriceToInvoicesAndInvoiceLines < ActiveRecord::Migration
  def self.up
    add_column :invoice_lines, :gross_price, :decimal
  end

  def self.down
    remove_column :invoice_lines, :gross_price
  end
end
