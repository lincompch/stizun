class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.string :company
      t.string :firstname
      t.string :lastname
      t.string :street
      t.string :postalcode
      t.string :city
      t.string :email
      t.integer :country_id
      t.integer :user_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :addresses
  end
end
