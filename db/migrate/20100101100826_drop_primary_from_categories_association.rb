class DropPrimaryFromCategoriesAssociation < ActiveRecord::Migration
  def self.up
    remove_column :categories_products, :id
  end

  def self.down
  end
end
