class AddIndexToProductPictures < ActiveRecord::Migration
  def change
  	add_index :product_pictures, :product_id
  end
end
