class AddIndexesForMarginRanges < ActiveRecord::Migration
  def up
    add_index :margin_ranges, :product_id
    add_index :margin_ranges, :supplier_id
  end

  def down
  end
end
