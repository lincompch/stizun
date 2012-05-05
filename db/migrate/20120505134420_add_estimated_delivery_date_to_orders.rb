class AddEstimatedDeliveryDateToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :estimated_delivery_date, :date
  end
end
