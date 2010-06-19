class CreateProductSetAssociation < ActiveRecord::Migration
  def self.up
    create_table :product_sets do |t|
      t.integer :quantity
      t.integer :product_id
      t.integer :component_id
    end
  end

  def self.down
  end
end
