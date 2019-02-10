class AddCategoryCacheToCategoryDispatchers < ActiveRecord::Migration
  def change
    add_column :category_dispatchers, :category_count, :integer, default: 0
  end
end
