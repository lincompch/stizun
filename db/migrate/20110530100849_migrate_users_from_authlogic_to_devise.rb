class MigrateUsersFromAuthlogicToDevise < ActiveRecord::Migration
  def self.up
    add_column :users, :reset_password_token, :string
    add_column :users, :remember_created_at, :datetime
    add_column :users, :authentication_token, :string

    rename_column :users, :crypted_password, :encrypted_password
    rename_column :users, :login_count, :sign_in_count
    rename_column :users, :current_login_at, :current_sign_in_at
    rename_column :users, :last_login_at, :last_sign_in_at
    rename_column :users, :current_login_ip, :current_sign_in_ip
    rename_column :users, :last_login_ip, :last_sign_in_ip


    remove_column :users, :persistence_token
    remove_column :users, :failed_login_count
    remove_column :users, :last_request_at
  end

  def self.down
    add_column :users, :persistence_token, :string
    add_column :users, :failder_login_count, :integer
    add_column :users, :last_request_at, :datetime

    rename_column :users, :encrypted_password, :crypted_password
    rename_column :users, :sign_in_count, :login_count
    rename_column :users, :current_sign_in_at, :current_login_at
    rename_column :users, :last_sign_in_at, :last_login_at
    rename_column :users, :current_sign_in_ip, :current_login_ip
    rename_column :users, :last_sign_in_ip, :last_login_ip

    remove_column :users, :reset_password_token
    remove_column :users, :remember_created_at
    remove_column :users, :authentication_token
  end
end
