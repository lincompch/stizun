class TaxClass < ActiveRecord::Base
  
  validates_presence_of :name, :percentage
  validates_numericality_of :percentage
  
  has_one :product
  has_one :shipping_cost
  has_one :shipping_rate # Shipping rates need this to calculate tax on fees
  has_one :shipping_calculator, :class_name => 'ShippingCalculators::ShippingCalculator'
  
  def to_s
    self.name + " (" + self.percentage.to_s + "%)"
  end
  
 
end
