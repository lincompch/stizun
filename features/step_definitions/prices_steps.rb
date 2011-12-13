Given /^a product$/ do
  @product = Product.new
  @product.name = "Some Product"
  @product.description = "Product Description"
  @product.save
end

Given /^a tax class named "([^\"]*)" with the percentage (\d+\.\d+)%$/ do |arg1, arg2|
  TaxClass.create(:name => arg1, :percentage => arg2)
end

When /^I set the purchase price to (\d+\.\d+)$/ do  |num|
  @product.purchase_price = BigDecimal.new(num)
end

When /^I set the tax class to "([^\"]*)"$/ do |arg1|
  
  # TODO: This is dummy material -- needs to be updated with an elegant way to specify
  # both tax class names and tax class percentages in the .feature
  @tc = TaxClass.find_by_name(arg1)
  @product.tax_class = @tc
end

When /^I set the absolute sales price to (\d+\.\d+)$/ do |num|
  @product.sales_price = BigDecimal.new(num)
end

Then /^the taxed product price should be (\d+\.\d+)$/ do |num|
  @product.taxed_price.should == BigDecimal.new(num)
end

Then /^the taxed rounded price should be (\d+\.\d+)$/ do |num|
  @product.taxed_price.rounded.should == BigDecimal.new(num)
end

Then /^the absolute margin should be (\d+\.\d+)$/ do |num|
  @product.margin.should == BigDecimal.new(num)
end

Then /^the taxes should be (\d+\.\d+)$/ do |num|
  @product.taxes.should == BigDecimal.new(num)
end

Then /^the taxes should be roughly (\d+\.\d+)$/ do |num|
  # TODO: This is a bit fishy, is it really as inaccurate as it seems? Let's move all the
  # tests to "should be", not "should be roughly"
  @product.taxes.floor(13).should == BigDecimal.new(num).floor(13)
end