Given "a minimimal working system setup" do

  p1 = FactoryGirl.create(:product, :name => 'Minimal 1')
  p2 = FactoryGirl.create(:product, :name => 'Minimal 2')
  
  mr = FactoryGirl.create(:margin_range)
  c = FactoryGirl.create(:country)


  sc = ShippingCalculatorBasedOnWeight.create(:name => 'Minimal SC')
  sc.configuration.shipping_costs = []
  sc.configuration.shipping_costs << {:weight_min => 0, :weight_max => 2000, :price => 8.35}
  sc.configuration.shipping_costs << {:weight_min => 2001, :weight_max => 5000, :price => 10.20}
  sc.configuration.shipping_costs << {:weight_min => 5001, :weight_max => 31000, :price => 15.20}
  sc.tax_class = FactoryGirl.create(:tax_class)
  sc.save
  ConfigurationItem.create(:key => 'default_shipping_calculator_id', :value => sc.id)

end

When "I start the debugger" do
  debugger; puts "lalala!"
end


When /^I wait for (\d+) seconds$/ do |num|
  sleep(num.to_f)
end
