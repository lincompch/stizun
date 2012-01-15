class RemoveTypeToPreventSti < ActiveRecord::Migration
  def change
    remove_column :shipping_calculators, :type
  end
end
