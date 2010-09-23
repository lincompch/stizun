class AddTypeToHistory < ActiveRecord::Migration
  def self.up
    add_column :histories, :type, :integer
  end

  def self.down
    remove_column :histories, :type
  end
end
