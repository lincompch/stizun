class AddUsergroups < ActiveRecord::Migration
  def self.up
    create_table :usergroups do |t|
      t.string :name
      t.boolean :is_admin
    end 
    create_table :usergroups_users, :id => false do |t|
      t.integer :usergroup_id
      t.integer :user_id
    end
    Usergroup.find_or_create_by_name(:name => 'Admins', :is_admin => true)
  end

  def self.down
    drop_table :usergroups
    drop_table :usergroups_users
  end
end
