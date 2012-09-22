class CreateCategoryDispatchers < ActiveRecord::Migration
  def change
    create_table :category_dispatchers do |t|

      t.integer :id
      t.text :level_01
      t.text :level_02
      t.text :level_03
      t.integer :supplier_id
      t.integer :target_category_id
      t.timestamps
    end
  end
end
