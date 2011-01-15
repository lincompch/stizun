class AddShortDescriptionToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :short_description, :text
  end

  def self.down
    remove_column :products, :short_description
  end
end
