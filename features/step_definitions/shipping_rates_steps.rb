Given /^there is a shipping rate called "([^\"]*)" with the following costs:$/ do |name, table|  
  @shipping_rate = ShippingRate.create(:name => name)
  table.hashes.each do |sc|
    tc = TaxClass.create(:name => sc['tax_percentage'], :percentage => sc['tax_percentage'])
    @shipping_rate.shipping_costs << ShippingCost.create(:weight_min => sc['weight_min'],
                                                         :weight_max => sc['weight_max'],
                                                         :price => BigDecimal(sc['price'].to_s),
                                                         :tax_class => tc
                                                        )
  end

end

Given /^an order with the following products:$/ do |table|  
  Numerator.create(:count => 0)
  
  billing_address = Address.create(:firstname => 'Elvis', 
                                   :lastname => 'Presley', 
                                   :street => 'XYZ', 
                                   :email => 'elvis@elvis.com', 
                                   :postalcode => 1234, 
                                   :city => 'grarg', 
                                   :country => Country.create(:name => 'USAnia')
                                  )  
  user = User.new
  user.addresses << billing_address
  user.payment_methods << PaymentMethod.find_by_name("Invoice")   
  user.payment_methods << PaymentMethod.find_by_name("Prepay")   
  user.save

  @order = Order.new(:billing_address => billing_address)
  

  
  table.hashes.each do |prod|
    purchase_price = 0
    purchase_price = BigDecimal.new(prod['purchase_price'].to_s) if prod['purchase_price']
    margin_percentage = 0.0
    margin_percentage = prod['margin_percentage'].to_f if prod['margin_percentage']
  
    tax_class = TaxClass.find_by_name(prod['tax_class']) 
    supplier = Supplier.find_by_name(prod['supplier'])
    product = Product.create(:name => prod['name'],
                             :description => 'foobar',
                             :weight => prod['weight'],
                             :sales_price => BigDecimal('22.0'),
                             :supplier => supplier,
                             :tax_class => tax_class,
                             :purchase_price => purchase_price,
                             :margin_percentage => margin_percentage)
    
   
    @order.order_lines << OrderLine.new(:quantity => prod['quantity'].to_i, :product => product)
  end
  @order.user = user
  @order.save
end                                                                                                

Given /^there are the following suppliers:$/ do |table|  
  table.hashes.each do |sup|
    supplier = Supplier.find_or_create_by_name(sup['name'])
    shipping_rate = ShippingRate.find_by_name(sup['shipping_rate_name'])
    supplier.shipping_rate = shipping_rate
    supplier.save
 end
end

Given /^there is a payment method called "([^\"]*)" which does not allow direct shipping and is the default$/ do |name|  
  PaymentMethod.create(:name => name, :allows_direct_shipping => false, :default => true)
end

Given /^there is a payment method called "([^\"]*)" which allows direct shipping$/ do |name|  
  PaymentMethod.create(:name => name, :allows_direct_shipping => true, :default => false)
end

Given /^the order's payment method is "([^\"]*)"$/ do |name|  
  @order.payment_method = PaymentMethod.find_by_name(name)
  @order.save
end

When /^I calculate the shipping rate for the order$/ do
  @order.shipping_rate
end  

Then /^the order's total weight should be (\d+\.\d+)$/ do |num|
  @order.weight.should == num.to_f
end    
                                                                                                  
Then /^the order's outgoing shipping price should be (\d+\.\d+)$/ do |num|
 
  puts "rate is :" + @order.shipping_rate.outgoing_cost.to_s
  @order.shipping_rate.outgoing_cost.should == BigDecimal.new(num.to_s)
end

Then /^the order's taxes should be (\d+\.\d+)$/ do |num|
  @order.shipping_rate.total_taxes.should == BigDecimal.new(num.to_s)
end


Then /^the order's outgoing package count should be (\d+)$/ do |num|
  @order.shipping_rate.outgoing_package_count.should == num.to_i
end

Then /^the order's incoming package count should be (\d+)$/ do |num|
  @order.shipping_rate.incoming_package_count.should == num.to_i
end
                                                                                                  
Then /^the order's incoming shipping price should be (\d+\.\d+)$/ do |num|
   @order.shipping_rate.incoming_cost.should == BigDecimal.new(num.to_s)
end

  
