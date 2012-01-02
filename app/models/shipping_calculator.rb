class ShippingCalculator < ActiveRecord::Base

  serialize :configuration, OpenStruct
  belongs_to :tax_class

  def after_initialize
    @cost = BigDecimal.new("0")
    @taxes = BigDecimal.new("0")
    @gross_cost = BigDecimal.new("0")
    @package_count = 0    
  end
  
  # Define this method on the child classes
  def calculate_for
    
  end
  
  def cost
    return @cost
  end
  
  def taxes
    return @taxes
  end
  
  def package_count
    return @package_count
  end
  
  
end