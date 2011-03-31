class CreateShippingCarriers < ActiveRecord::Migration
  def self.up
    create_table :shipping_carriers do |t|
      t.string :name
      t.string :tracking_base_url
    end
  end

  def self.down
    drop_table :shipping_carriers
  end
end
