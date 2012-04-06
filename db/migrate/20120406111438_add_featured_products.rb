class AddFeaturedProducts < ActiveRecord::Migration
  def up
    add_column :products, :is_featured, :boolean
  end

  def down
    remove_column :products, :is_featured
  end
end
