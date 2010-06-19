class CreateAdminAddresses < ActiveRecord::Migration
  def self.up
    create_table :admin_addresses do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :admin_addresses
  end
end
