class AddIndexToSupplierIdOnCategoryDispatchers < ActiveRecord::Migration
  def change
    add_index :category_dispatchers, :supplier_id
  end
end
