class AddSupplierUtilClassNameToSuppliers < ActiveRecord::Migration
  def self.up
    add_column :suppliers, :utility_class_name, :string
  end

  def self.down
    remove_column :suppliers, :utility_class_name
  end
end
