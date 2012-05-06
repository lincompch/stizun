class CreateTrackingCodes < ActiveRecord::Migration
  def up
    create_table :tracking_codes do |t|
      t.timestamps
      t.integer :shipping_carrier_id
      t.integer :order_id
      t.string :tracking_code
    end

    Order.all.each do |o|
      unless o.shipping_carrier_id.blank? and o.tracking_number.blank?
        o.tracking_codes.build(:shipping_carrier_id => o.shipping_carrier_id,
                               :tracking_code => o.tracking_number)
        o.save
      end
    end

  end

  def down
    remove_table :tracking_codes
  end
end
