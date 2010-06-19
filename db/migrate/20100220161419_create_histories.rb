class CreateHistories < ActiveRecord::Migration
  def self.up
    create_table :histories do |t|
      t.string :text
      t.string :object_type
      t.integer :object_id

      t.timestamps
    end
  end

  def self.down
    drop_table :histories
  end
end
