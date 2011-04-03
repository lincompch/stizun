class SingleUntaxedPriceForInvoices < ActiveRecord::Migration
  def self.up
    add_column :static_document_lines, :single_untaxed_price, :decimal, :precision => 63, :scale => 30
  end

  def self.down
    remove_column :static_document_lines, :single_untaxed_price
  end
end
