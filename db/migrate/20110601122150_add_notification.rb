class AddNotification < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.string :email
      t.string :remove_hash
      t.integer :product_id
      t.integer :user_id
      t.boolean :active

      t.timestamps
    end
  end

  def self.down
    drop_table :notification
  end
end
