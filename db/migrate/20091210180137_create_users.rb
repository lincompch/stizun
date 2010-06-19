class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :login
      t.string :crypted_password
      t.string :password_salt
      t.timestamps
      t.string :persistence_token
    end
  end

  def self.down
    drop_table :users
  end
end
