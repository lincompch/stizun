class CreateFeedEntries < ActiveRecord::Migration
  def self.up
    create_table :feed_entries do |t|
      t.string :title
      t.text :content
      t.string :url
      t.string :guid
      t.datetime :published_at

      t.timestamps
    end
  end

  def self.down
    drop_table :feed_entries
  end
end
