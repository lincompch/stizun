class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string :name
      t.string :description
      t.integer :tax_class_id
      t.decimal :purchase_price, :precision => 20, :scale => 2, :default => 0
      t.decimal :margin_percentage, :precision => 8, :scale => 2, :default => 0
      t.decimal :sales_price, :precision => 20, :scale => 2, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :products
  end
end
