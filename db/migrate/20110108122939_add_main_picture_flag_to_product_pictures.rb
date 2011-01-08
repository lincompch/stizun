class AddMainPictureFlagToProductPictures < ActiveRecord::Migration
  def self.up
    add_column :product_pictures, :is_main_picture, :boolean
  end

  def self.down
    remove_column :product_pictures, :is_main_picture
  end
end
