class AddPdfUrlToSupplyItems < ActiveRecord::Migration
  def self.up
    
    add_column :supply_items, :pdf_url, :text
    
  end

  def self.down
    remove_column :supply_items, :pdf_url
  end
end
