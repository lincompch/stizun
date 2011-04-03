class SwitchOrderToOldOrderAndCreateStaticDocuments < ActiveRecord::Migration
  def self.up
    rename_table :orders, :old_orders
    rename_table :invoice_lines, :static_document_lines
    
    create_table :orders do |t|
      t.timestamps
      t.integer  "shipping_address_id"
      t.string   "shipping_address_type"
      t.integer  "billing_address_id"
      t.string   "billing_address_type"
      t.integer  "user_id"
      t.integer  "status_constant",                                       :default => 1
      t.string   "uuid"
      t.decimal  "shipping_cost",         :precision => 63, :scale => 30
      t.integer  "payment_method_id"
      t.integer  "document_number"
      t.decimal  "shipping_taxes",        :precision => 63, :scale => 30
      t.integer  "shipping_carrier_id"
      t.string   "tracking_number"
      t.boolean  "direct_shipping", :default => false
    end
    
    add_column :static_document_lines, :order_id, :integer
    
  end

  def self.down
    drop_table :orders
    rename_table :old_orders, :orders
    remove_column :static_document_lines, :order_id
    rename_table :static_document_lines, :invoice_lines
  end
end
