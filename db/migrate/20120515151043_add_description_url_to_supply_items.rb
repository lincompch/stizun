class AddDescriptionUrlToSupplyItems < ActiveRecord::Migration
  def change
    add_column :supply_items, :description_url, :text
  end
end
