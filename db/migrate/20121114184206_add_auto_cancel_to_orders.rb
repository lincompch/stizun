class AddAutoCancelToOrders < ActiveRecord::Migration
  def up
    add_column :orders, :auto_cancel, :boolean, :default => true
    Order.all.each do |o|
      o.auto_cancel = false
      if o.save
        puts "Order #{o.document_id} set to auto-cancel = false"
      else
        puts "Order #{o.document_id} could not be set to auto-cancel = false"
      end
    end
  end
  def down
    remove_column :orders, :auto_cancel
  end
end
