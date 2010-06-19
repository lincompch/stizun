class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name
      t.integer :parent_id

      t.timestamps
    end
    
    create_table :categories_products do |t|
      t.references :category, :product
      
    end
    
    add_index :categories_products, :category_id
    add_index :categories_products, :product_id

  end

  def self.down
    drop_table :categories
    drop_table :categories_products
  end
end
