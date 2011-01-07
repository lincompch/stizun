class AddAttachmentFileToPicture < ActiveRecord::Migration
  def self.up
    create_table :product_pictures do |t|
      t.integer :product_id 
      t.string :file_file_name
      t.string :file_content_type
      t.integer :file_file_size
      t.datetime :file_updated_at
    end
    
  end

  def self.down
    drop_table :product_pictures
  end
end