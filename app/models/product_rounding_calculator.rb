class ProductRoundingCalculator



  def self.calculate_rounding_component(options)
    rounding_component = BigDecimal.new("0.0")
 
    # Depending on how the system is configured, we can pick which rounding behavior to use
    begin
      rounding_component_rule = ConfigurationItem.get("rounding_component_rules").value
      method_name = "calculate_#{rounding_component_rule}_rounding_component"

      if self.methods.include?(method_name.to_sym)
        rounding_component = self.send(method_name, options)
      else
        logger.error("Rounding method #'#{method_name}' not found in ProductRoundingCalculator, therefore returning 0.0 as rounding component")
      end
    rescue ArgumentError
      # Doing nothing here -- rounding component was set to 0.0 earlier anyhow, it's safe to return
    end
    return rounding_component
  end


  # In Switzerland, only 0.05 coins exist, therefore we must try to get as close as possible to a sales price
  # that ends in .05, otherwise various price rounding calculations lead to situations where the price displayed
  # for a single item is not the same as for buying several of those items in bulk (e.g. 2 * 144.02 = 288.04, rounded to 288.05, even
  # though a single item of the same kind would display as 144.00 in the store.
  def self.calculate_swiss_rounding_component(options)
    purchase_price = options[:purchase_price]
    margin_percentage = options[:margin_percentage]
    tax_percentage = options[:tax_percentage]
    absolute_rebate = options[:absolute_rebate]
    percentage_rebate = options[:percentage_rebate]

    rebate = self.calculate_rebate(purchase_price, absolute_rebate, percentage_rebate)

    swiss_rounding_component = BigDecimal.new("0.0")
    margin = (purchase_price / BigDecimal.new("100.0")) * BigDecimal.new(margin_percentage.to_s) # Duplicated from product.rb
    taxes = ( (purchase_price + margin - rebate) / BigDecimal.new("100.0")) * tax_percentage # Duplicated from product.rb
    anticipated_sales_price = (purchase_price + margin + taxes)
    if ((anticipated_sales_price * 100) % 5).to_s != "0.0"
      new_price = (anticipated_sales_price/BigDecimal.new("5")).round(2, BigDecimal::ROUND_UP) * BigDecimal.new("5")
      new_price_without_taxes = (new_price / (BigDecimal.new("100.0") + tax_percentage)) * BigDecimal.new("100.0")
      new_price_without_margin = (new_price_without_taxes / BigDecimal.new((100 + margin_percentage).to_s) * BigDecimal.new("100.0"))
      swiss_rounding_component = new_price_without_margin - purchase_price
    end
    return swiss_rounding_component
  end

  # Duplicated from product.rb, couldn't find any other way to do this without infinite loops before saving a product
  def self.calculate_rebate(full_price, absolute_rebate, percentage_rebate)
    rebate = BigDecimal.new("0")
     
    if !absolute_rebate.blank? and absolute_rebate > 0
     rebate = absolute_rebate
    elsif !percentage_rebate.blank? and percentage_rebate > 0
     rebate = (full_price / BigDecimal.new("100.0")) * percentage_rebate
    end

    return rebate
  end


end
