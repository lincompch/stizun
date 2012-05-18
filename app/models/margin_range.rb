class MarginRange < ActiveRecord::Base
  
  belongs_to :supplier
  belongs_to :product

  validate :cannot_be_for_supplier_and_product_simultaneously

  def self.percentage_for_price(price, ranges = nil)
    percentage = 5.0
    price = price.to_i
    ranges = MarginRange.where(:supplier_id => nil, :product_id => nil) if ranges.nil?
    range = ranges.where("start_price <= ? AND end_price >= ?", price, price).first
    if range.nil?
      range = ranges.where("start_price IS ? AND end_price IS ?", nil, nil).first 
    end
    percentage = range.margin_percentage unless range.nil?
    return percentage
  end

  def cannot_be_for_supplier_and_product_simultaneously
    unless product_id.blank? or supplier_id.blank?
      errors.add("MarginRange", "cannot be applied to suppliers and products at the same time. Only to one or none of them.")
    end
  end

end
