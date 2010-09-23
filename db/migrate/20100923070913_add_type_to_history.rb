class AddTypeToHistory < ActiveRecord::Migration
  def self.up
    add_column :histories, :type_const, :integer
  end

  def self.down
    remove_column :histories, :type_const
  end
end
