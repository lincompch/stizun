class CreateSupplyItems < ActiveRecord::Migration
  def self.up
    create_table :supply_items do |t|
      t.string :supplier_product_code
      t.string :name
      t.float :weight
      t.integer :supplier_id
      t.string :description
      t.decimal :purchase_price, :precision => 20, :scale => 2, :default => 0
      t.integer :stock
      t.timestamps
    end
  end

  def self.down
    drop_table :supply_items
  end
end