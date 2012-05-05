class ShippingCalculatorBasedOnWeight < ShippingCalculator
  
  validates_presence_of :configuration
  validate :validate_configuration
  
  def calculate_for(document)
    @cost = calculate_for_weight(document.weight * 1000)
    @package_count = package_count_for_weight(document.weight * 1000)
  end
  
  # Input: Weight in grams
  # Output: Price for delivery according to configured ShippingCosts
  def calculate_for_weight(weight)
    cost = 0
    remaining_weight ||= weight.to_f
    
    if remaining_weight <= 0.0
      matching_cost = self.configuration.shipping_costs.first
      cost += matching_cost[:price]
      remaining_weight = 0.0
    else

      while remaining_weight > 0.0
        matching_cost = nil
        
        # The weight is too high to fit into one package, we pick the highest-weight
        # shipping rate, reduce the remaining weight and continue with the rest of the weight (this splits
        # orders into multiple packages)
        if remaining_weight > self.maximum_weight
          remaining_weight = (remaining_weight - self.maximum_weight)
          self.configuration.shipping_costs.each do |sc|         
            matching_cost = sc if sc[:weight_max].to_f == self.maximum_weight.to_f
          end
        else
          
          shipping_cost = nil
          self.configuration.shipping_costs.each do |sc|
            if remaining_weight.between?(sc[:weight_min].to_f, sc[:weight_max].to_f)
              shipping_cost = sc
            end
          end
          
          if shipping_cost.nil?
            # No shipping cost was found that matches the weight of this order
            # so we assume the order is below the lowest weight and pick the first
            # shipping cost of this supplier
            matching_cost = self.configuration.shipping_costs.first
            puts "picked matching cost: #{matching_cost}"
            remaining_weight = 0
          else
            # A match was found, the weight is between two available shipping costs
            matching_cost = shipping_cost
            remaining_weight = 0
          end
        end
        # Add the prices of the matching shipping cost that was found above
        cost += matching_cost[:price]
      end
      
    end

    return BigDecimal.new(cost.to_s)
  end
  
  # Input: Weight in grams
  # Output: Integer representing the number of packages necessary to ship
  #         items as heavy as the input weight.
  def package_count_for_weight(weight)
    (weight.to_f / self.maximum_weight).ceil
  end
  
  # Maximum weight carried by this ShippingRate's ShippingCosts, in grams
  def maximum_weight
    max = 0
    self.configuration.shipping_costs.each do |sc|
      max = sc[:weight_max] if sc[:weight_max] > max
    end
    return max.to_f
  end
  
  def validate_configuration
    # Only validate if there is actually a configuration sent into us
    # Very evil hack because calling .blank? doesn't actually return true even when the
    # OpenStruct is empty
    unless self.configuration.inspect == "#<OpenStruct>"
      if self.configuration.shipping_costs.blank?
        errors.add(:shipping_costs, "can't be blank")
      else
        self.configuration.shipping_costs.each do |sc|
          errors.add(:shipping_costs, "minimum weights must be smaller than their maximum counterpart (#{sc[:weight_min]} < #{sc[:weight_max]})") if sc[:weight_min] > sc[:weight_max]
          errors.add(:shipping_costs, "minimum and maximum weights may not be the same (#{sc[:weight_min]} == #{sc[:weight_max]})") if sc[:weight_min] == sc[:weight_max]
        end
      end
    end
  end
  
  
end
