class LongerProductDescriptions < ActiveRecord::Migration
  def up
    change_column :supply_items, :description, :text
  end

  def down
  end
end
