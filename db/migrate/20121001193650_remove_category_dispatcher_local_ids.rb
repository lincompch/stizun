class RemoveCategoryDispatcherLocalIds < ActiveRecord::Migration
  def up
    remove_column :category_dispatchers, :target_category_id
  end

  def down
    add_column :category_dispatchers, :target_category_id, :integer
  end
end
