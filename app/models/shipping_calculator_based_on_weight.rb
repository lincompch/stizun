class ShippingCalculatorBasedOnWeight < ShippingCalculator
  
  def calculate_for(document)
    
      self.configuration.shipping_costs = []
      self.configuration.shipping_costs << {:weight_min => 0, :weight_max => 2000, :price => 8.35}
      self.configuration.shipping_costs << {:weight_min => 2001, :weight_max => 5000, :price => 10.20}
      self.configuration.shipping_costs << {:weight_min => 5001, :weight_max => 31000, :price => 15.20}
    
    @cost = calculate_for_weight(document.weight * 1000)
    @package_count = package_count_for_weight(document.weight * 1000)
  end
  
  # Input: Weight in grams
  # Output: Price for delivery according to configured ShippingCosts
  def calculate_for_weight(weight)
    @remaining_weight ||= weight  
    
    while @remaining_weight > 0.to_f

      # The weight is too high to fit into one package, we pick this supplier's highest-weight
      # shipping rate, reduce the remaining weight and continue with the rest of the weight (this splits
      # orders into multiple packages)
      if @remaining_weight > self.maximum_weight
        @remaining_weight = (@remaining_weight - self.maximum_weight)
        matching_cost = self.configuration.shipping_costs.select{|s| s.weight_max == self.maximum_weight}.first
      else
        
        shipping_cost = self.configuration.shipping_costs.select{ |sc| @remaining_weight.between?(sc.weight_min, sc.weight_max) }
        if shipping_cost.blank?
          # No shipping cost was found that matches the weight of this order
          # so we assume the order is below the lowest weight and pick the first
          # shipping cost of this supplier
          matching_cost = self.configuration.shipping_costs.first
          @remaining_weight -= @remaining_weight
          
        else
          # A match was found, the weight is between two available shipping rates (shipping_cost.first is this rate)
          matching_cost = shipping_cost.first
          @remaining_weight -= @remaining_weight
        end
      end
      
      # Add the prices of the matching shipping cost that was found above
      @cost += matching_cost.price
    end
    
    return BigDecimal.new(@cost.to_s)
  end
  
  # Input: Weight in grams
  # Output: Integer representing the number of packages necessary to ship
  #         items as heavy as the input weight.
  def package_count_for_weight(weight)
    (weight / self.maximum_weight).ceil
  end
  
  # Maximum weight carried by this ShippingRate's ShippingCosts, in grams
  def maximum_weight
    max = 0
    self.configuration.shipping_costs.each do |sc|
      max = sc[:weight_max] if sc[:weight_max] > max
    end
    return max
  end
  
  
end