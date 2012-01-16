class RemoveTypeToPreventSti < ActiveRecord::Migration
  def up
    remove_column :shipping_calculators, :type
  end
  
  def down
    add_column :shipping_calculators, :type, :string
  end
end
