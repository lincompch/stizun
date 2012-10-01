class HabtmBetweenCategoryDispatchersAndCategories < ActiveRecord::Migration
  def up
    create_table :categories_category_dispatchers do |t|
      t.integer :category_id
      t.integer :category_dispatcher_id
    end
  end

  def down
    drop_table :categories_category_dispatchers
  end
end
