class LinkShippingCostsToTaxRates < ActiveRecord::Migration
  def self.up
    add_column :shipping_costs, :tax_class_id, :integer
  end

  def self.down
    remove_column :shipping_costs, :tax_class_id, :integer
  end
end
