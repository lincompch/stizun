class TaxClass < ActiveRecord::Base
  
  validates_presence_of :name, :percentage
  validates_numericality_of :percentage
  
  has_one :product
  has_one :shipping_calculator
  
  def to_s
    self.name + " (" + self.percentage.to_s + "%)"
  end
  
 
end
