class AddStatusToAddresses < ActiveRecord::Migration
  def self.up
    add_column :addresses, :status, :string, :default => 'active'
  end

  def self.down
    remove_column :addresses, :status
  end
end
