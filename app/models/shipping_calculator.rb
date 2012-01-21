require 'ostruct'

class ShippingCalculator < ActiveRecord::Base
      
  serialize :configuration, OpenStruct
  belongs_to :tax_class
  validates_presence_of :tax_class_id, :name
  validates_uniqueness_of :name

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
  end
  
  def calculate_for(document)
    # Define this method as a subclass
    calculator = self.configuration.behavior.constantize.new
    calculator.calculate_for(document)
    @cost = calculator.cost
    @package_count = calculator.package_count
  end
  
  def self.get_default
    begin
      default_calculator_id = ConfigurationItem.get("default_shipping_calculator_id").value
      default_calculator = ShippingCalculator.find(default_calculator_id)
      return default_calculator      
    rescue ArgumentError
      logger.error("Fatal error: Default shipping calculator is not defined. Please create one and define configuration item: default_shipping_calculator_id")
      raise "Fatal error: Default shipping calculator is not defined. Please create one and define configuration item: default_shipping_calculator_id"
    end
  end
  
  def cost
    return @cost
  end
  
  def taxes
    @taxes = (self.cost / BigDecimal.new("100.0")) * self.tax_class.percentage
    return @taxes
  end
  
  def package_count
    return @package_count
  end
  
  
end


