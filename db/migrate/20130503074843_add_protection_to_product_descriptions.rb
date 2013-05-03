class AddProtectionToProductDescriptions < ActiveRecord::Migration
  def change
    add_column :products, :is_description_protected, :boolean, :default => false
  end
end
