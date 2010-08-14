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
  supplier = Supplier.new(:name => 'Some Supplier')
  supplier.shipping_rate = @shipping_rate
  supplier.save
  
  tax_class = TaxClass.create(:name => 'something', :percentage => 5.0)
  
  billing_address = Address.create(:firstname => 'Elvis', 
                                   :lastname => 'Presley', 
                                   :street => 'XYZ', 
                                   :email => 'elvis@elvis.com', 
                                   :postalcode => 1234, 
                                   :city => 'grarg', 
                                   :country => Country.create(:name => 'USAnia')
                                  )  
  
  @order = Order.new(:billing_address => billing_address)
  
  table.hashes.each do |prod|
    puts "adding product #{prod['name']} with weight #{prod['weight']}"
    product = Product.create(:name => prod['name'],
                             :description => 'foobar',
                             :weight => prod['weight'],
                             :sales_price => BigDecimal('22.0'),
                             :supplier => supplier,
                             :tax_class => tax_class)
    
   
    @order.order_lines << OrderLine.new(:quantity => prod['quantity'].to_i, :product => product)
  end
  @order.save
end                                                                                                


Given /^there is a payment method called "([^\"]*)" which does not allow direct shipping and is the default$/ do |name|  
  PaymentMethod.create(:name => name, :allows_direct_shipping => false, :default => true)
end

Given /^there is a payment method called "([^\"]*)" which allows direct shipping$/ do |name|  
  PaymentMethod.create(:name => name, :allows_direct_shipping => true, :default => false)
end


When /^I calculate the shipping rate for the order$/ do
  @order.shipping_rate
end  

Then /^the order's total weight should be (\d+\.\d+)$/ do |num|
  @order.weight.should == num.to_f
end    
                                                                                                  
Then /^the order's outgoing shipping price should be (\d+\.\d+)$/ do |num|
  @order.shipping_rate.outgoing_cost.should == BigDecimal.new(num.to_s)
end

Then /^the order's outgoing package count should be (\d+)$/ do |num|
  @order.shipping_rate.outgoing_package_count.should == num.to_i
end
