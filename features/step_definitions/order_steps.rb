Then /^the order's total weight should be (\d+\.\d+)$/ do |num|
  @order.weight.should == num.to_f
end    

Then /^the order's outgoing shipping price should be (\d+\.\d+)$/ do |num|
#   
#   puts "this rate: #{@order.shipping_rate.inspect}"
#   puts "this out cost: #{@order.shipping_rate.outgoing_cost.to_s}"
#   puts "all rates: #{ShippingRate.all.inspect}"
#

  @order.shipping_cost.should == BigDecimal.new(num.to_s)
end

Then /^the order's shipping taxes should be (\d+\.\d+)$/ do |num|
  @order.shipping_taxes.should == BigDecimal.new(num.to_s)
end

Then /^the order's taxed price should be (\d+\.\d+)$/ do |num|
  @order.taxed_price.should == BigDecimal.new(num.to_s)
end

Then /^the order's taxes should be (\d+\.\d+)$/ do |num|
  @order.taxes.should == BigDecimal.new(num.to_s)
end

Then /^the order's products total taxed price should be (\d+\.\d+)$/ do |num|
  @order.products_taxed_price.should == BigDecimal.new(num.to_s)
end

Then /^the order's products total untaxed price should be (\d+\.\d+)$/ do |num|
  @order.products_price.should == BigDecimal.new(num.to_s)
end