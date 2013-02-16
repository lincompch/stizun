class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string :url
      t.string :description
      t.integer :product_id

      t.timestamps
    end
  end
end
