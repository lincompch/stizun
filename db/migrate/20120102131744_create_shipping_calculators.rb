class CreateShippingCalculators < ActiveRecord::Migration
  def change
    create_table :shipping_calculators do |t|
      t.string :name
      t.text :configuration
      t.string :type
      t.integer :tax_class_id
    end
  
  end
end
