class AssignCategoriesToSuppliers < ActiveRecord::Migration
  def self.up
    add_column :categories, :supplier_id, :integer
  end

  def self.down
    remove_column :categories, :supplier_id
  end
end
