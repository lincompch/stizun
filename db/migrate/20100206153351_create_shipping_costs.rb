class CreateShippingCosts < ActiveRecord::Migration
  def self.up
    create_table :shipping_costs do |t|
      t.integer :shipping_rate_id
      t.integer :weight_min
      t.integer :weight_max
      t.decimal :price, :scale => 30, :precision => 63
      t.timestamps
    end
  end

  def self.down
    drop_table :shipping_costs
  end
end
