class CreateSuppliers < ActiveRecord::Migration
  def self.up
    create_table :suppliers do |t|
      t.string :name
      t.integer :address_id
      t.integer :shipping_rate_id
      t.timestamps
    end
    
    add_column :products, :supplier_id, :integer

  end

  def self.down
    drop_table :suppliers
  end
end
