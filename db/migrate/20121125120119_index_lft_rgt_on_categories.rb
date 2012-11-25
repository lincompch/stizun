class IndexLftRgtOnCategories < ActiveRecord::Migration
  def up
    add_index :categories, :lft
    add_index :categories, :rgt
  end

  def down
    remove_index :categories, :lft
    remove_index :categories, :rgt
  end
end
