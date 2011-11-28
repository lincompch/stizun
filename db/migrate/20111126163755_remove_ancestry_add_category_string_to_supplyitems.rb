class RemoveAncestryAddCategoryStringToSupplyitems < ActiveRecord::Migration
  def up
    remove_column :categories, :ancestry
    remove_column :supply_items, :category_id
    add_column :supply_items, :category_string, :string
  end

  def down
    add_column :supply_items, :category_id, :integer
    add_column :categories, :ancestry, :string
    remove_column :supply_items, :category_string
  end
end
