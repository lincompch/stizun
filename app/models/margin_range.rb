class MarginRange < ActiveRecord::Base
  
  def self.percentage_for_price(price)
    percentage = 5.0
    price = price.to_i
    range = self.where("start_price <= ? AND end_price >= ?", price, price).first
    if range.nil?
      range = self.where("start_price IS ? AND end_price IS ?", nil, nil).first 
    end
    percentage = range.margin_percentage unless range.nil?
    return percentage
  end
  
end