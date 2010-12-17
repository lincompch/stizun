class SeparateInvoiceLines < ActiveRecord::Migration
  def self.up
    create_table :invoice_lines do |t|
      t.integer :quantity
      t.string :text
      t.decimal :rounded_price, :scale => 30, :precision => 63
      t.decimal :single_rounded_price, :scale => 30, :precision => 63
      t.decimal :taxes, :scale => 30, :precision => 63
      t.decimal :tax_percentage, :precision => 8, :scale => 2
      t.integer :invoice_id
      t.float :weight
      t.timestamps
    end

    add_column :invoices, :shipping_cost, :decimal, :scale => 30, :precision => 63
  end

  def self.down
    drop_table :invoice_lines
    remove_column :invoices, :shipping_cost
  end
end
