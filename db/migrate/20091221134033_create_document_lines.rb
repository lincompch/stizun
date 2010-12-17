class CreateDocumentLines < ActiveRecord::Migration
  def self.up
    create_table :document_lines do |t|
      t.integer :quantity
      t.decimal :price
      # Without the scale, MySQL will erroneously truncate things to 
      # integer with ActiveRecord, which is fucked up beyond all hope.
      # WITH the scale, we lose the arbitrary precision of BigDecimals. Fantastic!
      t.decimal :tax, :scale => 30, :precision => 63
      t.integer :product_id
      t.string :note
      t.string :type
      t.integer :cart_id
      t.integer :invoice_id
      t.integer :order_id

      t.timestamps
    end
  end

  def self.down
    drop_table :document_lines
  end
end
