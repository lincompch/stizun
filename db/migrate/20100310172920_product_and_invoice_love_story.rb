class ProductAndInvoiceLoveStory < ActiveRecord::Migration
  def self.up
    add_column :orders, :invoice_id, :integer
  end

  def self.down
    remove_column :orders, :invoice_id
  end
end
