# Allows us to round prices in a price-friendly way, e.g. to 0.05 precision
# for Switzerland, Finland and other nations without 0.01 and 0.02 coins.
class BigDecimal
  def rounded(divider = 5)
# That didn't reduce 288.036 to 288.00, which is what we wanted
    return (self/BigDecimal.new("#{divider}")).round(2, BigDecimal::ROUND_HALF_EVEN) * BigDecimal.new("#{divider}")  
  end
end
