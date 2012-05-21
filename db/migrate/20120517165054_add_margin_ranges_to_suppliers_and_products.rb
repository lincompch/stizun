class AddMarginRangesToSuppliersAndProducts < ActiveRecord::Migration
  def change
    add_column :margin_ranges, :product_id, :integer
    add_column :margin_ranges, :supplier_id, :integer
  end
end
