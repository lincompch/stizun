class LongerUrls < ActiveRecord::Migration
  def change
    change_column :supply_items, :product_link, :text
    change_column :products, :product_link, :text
    change_column :links, :url, :text
  end
end
