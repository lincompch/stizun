class AddImageUrlToSupplyItems < ActiveRecord::Migration
  def self.up
    add_column :supply_items, :image_url, :text
  end

  def self.down
    remove_column :supply_items, :image_url
  end
end
