class BuildToOrderCheckbox < ActiveRecord::Migration
  def up
    add_column :products, :is_build_to_order, :boolean, :default => false
  end

  def down
    remove_column :products, :is_build_to_order
  end
end
