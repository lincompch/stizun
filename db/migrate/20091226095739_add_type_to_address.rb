class AddTypeToAddress < ActiveRecord::Migration
  def self.up
    add_column :addresses, :type, :string
  end

  def self.down
    remove_column :addresses, :type
  end
end
