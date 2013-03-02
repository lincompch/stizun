class AddVisibilityToProducts < ActiveRecord::Migration
  def change
    add_column :products, :is_visible, :boolean, :default => true
    add_index :products, :is_visible
  end
end
