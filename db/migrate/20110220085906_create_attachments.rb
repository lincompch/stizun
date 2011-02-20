class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments do |t|
      t.integer :product_id
      t.string :file
    end
  end

  def self.down
    drop_table :attachments
  end
end
