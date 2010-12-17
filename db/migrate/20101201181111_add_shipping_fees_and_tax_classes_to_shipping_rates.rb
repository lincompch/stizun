class AddShippingFeesAndTaxClassesToShippingRates < ActiveRecord::Migration
  def self.up
    add_column :shipping_rates, :tax_class_id, :integer
    add_column :shipping_rates, :direct_shipping_fees, :decimal, :default => 0.0, :scale => 30, :precision => 63
  end

  def self.down
    remove_column :shipping_rates, :tax_class_id
    remove_column :shipping_rates, :direct_shipping_fees
  end
end
