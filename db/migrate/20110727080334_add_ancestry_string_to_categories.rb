class AddAncestryStringToCategories < ActiveRecord::Migration
  def self.up
    add_column :categories, :ancestry, :string
  end

  def self.down
    remove_column :categories, :ancestry
  end
end

