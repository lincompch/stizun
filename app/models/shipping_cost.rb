class ShippingCost < ActiveRecord::Base
  belongs_to :shipping_rate
  belongs_to :tax_class
  
  validates_presence_of :tax_class_id

  # Prices are gross for ShippingCost objects, taxes need to be added
  # separately.
  #
  # Taxes are handled by shipping cost, not by shipping rate, as e.g.
  # Swiss Post charges a lower amount of taxes for light shipments.
  def taxes
    return (price / BigDecimal.new("100")) * tax_class.percentage
  end
  
  # The net price (shipping cost price plus taxes)
  def taxed_price
    return price + taxes
  end
  
end
