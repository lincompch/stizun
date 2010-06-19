class CleanUpAddressColumns < ActiveRecord::Migration
  def self.up
    remove_column :addresses, :type
  end

  def self.down
  end
end
