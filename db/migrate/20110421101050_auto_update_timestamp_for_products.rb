class AutoUpdateTimestampForProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :auto_updated_at, :datetime
  end

  def self.down
    remove_column :products, :auto_updated_at
  end
end
