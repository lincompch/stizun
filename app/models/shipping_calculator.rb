require 'ostruct'

class ShippingCalculator < ActiveRecord::Base
      
  serialize :configuration, OpenStruct
  belongs_to :tax_class

  def self.inherited(child)  
    child.instance_eval do
      def model_name
        ShippingCalculator.model_name
      end
    end
    super 
  end

  def after_initialize
    @cost = BigDecimal.new("0")
    @taxes = BigDecimal.new("0")
    @gross_cost = BigDecimal.new("0")
    @package_count = 0    
    self.configuration.behavior ||= "ShippingCalculatorBasedOnWeight"
  end
  
  def calculate_for(document)
    # Define this method as a subclass
    calculator = self.configuration.behavior.constantize.new
    calculator.calculate_for(document)
    @cost = calculator.cost
    @package_count = calculator.package_count
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


