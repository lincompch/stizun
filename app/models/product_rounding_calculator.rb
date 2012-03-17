class ProductRoundingCalculator



  def self.calculate_rounding_component(purchase_price, margin_percentage, tax_percentage)
    # Depending on how the system is configured, we can pick which rounding behavior
    # to use. For the moment, we don't allow this to be configured at all, though, so
    # no need to read any configuration from anywhere :)
    return calculate_swiss_rounding_component(purchase_price, margin_percentage, tax_percentage)
  end


  # In Switzerland, only 0.05 coins exist, therefore we must try to get as close as possible to a sales price
  # that ends in .05, otherwise various price rounding calculations lead to situations where the price displayed
  # for a single item is not the same as for buying several of those items in bulk (e.g. 2 * 144.02 = 288.04, rounded to 288.05, even
  # though a single item of the same kind would display as 144.00 in the store.
  def calculate_swiss_rounding_component(purchase_price, margin_percentage, tax_percentage)
    swiss_rounding_component = BigDecimal.new("0.0")
    margin = (purchase_price / BigDecimal.new("100.0")) * BigDecimal.new(margin_percentage.to_s) # Duplicated from below
    taxes = ( (purchase_price + calculated_margin - rebate) / BigDecimal.new("100.0")) * tax_percentage # Duplicated from above
    anticipated_sales_price = (purchase_price + margin + taxes)
    if ((anticipated_sales_price * 100) % 5).to_s != "0.0"
#      new_purchase_price = anticipated_sales_price.round(1, BigDecimal::ROUND_UP)
      new_price = (anticipated_sales_price/BigDecimal.new("5")).round(2, BigDecimal::ROUND_UP) * BigDecimal.new("5")
      new_price_without_taxes = (new_price / (BigDecimal.new("100.0") + tax_percentage)) * BigDecimal.new("100.0")
      new_price_without_margin = (new_price_without_taxes / BigDecimal.new((100 + margin_percentage).to_s) * BigDecimal.new("100.0"))
      swiss_rounding_component = new_price_without_margin - purchase_price
    end
    return swiss_rounding_component
  end


end
