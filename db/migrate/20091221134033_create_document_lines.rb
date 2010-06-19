class CreateDocumentLines < ActiveRecord::Migration
  def self.up
    create_table :document_lines do |t|
      t.integer :quantity
      t.decimal :price
      t.decimal :tax
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
