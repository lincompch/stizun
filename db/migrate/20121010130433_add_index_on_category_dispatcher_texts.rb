class AddIndexOnCategoryDispatcherTexts < ActiveRecord::Migration
  def up
    add_index :category_dispatchers, :level_01, :length => 10
    add_index :category_dispatchers, :level_02, :length => 10
    add_index :category_dispatchers, :level_03, :length => 10
  end

  def down
    remove_index :category_dispatchers, :level_01
    remove_index :category_dispatchers, :level_02
    remove_index :category_dispatchers, :level_03
  end
end
