Given /^there is a shipping rate called "([^\"]*)" with the following costs:$/ do |name, table|  
  
  tax_class = TaxClass.find_or_create_by_percentage(:percentage => 8.0, :name => "8.0%")
  @shipping_rate = ShippingRate.create(:name => name, :tax_class => tax_class)
  
  # Only create and assign new costs if we don't have any yet on this 
  # @shipping_rate. Otherwise, leave stuff alone.
  if @shipping_rate.shipping_costs.count == 0
    table.hashes.each do |sc|
      tc = TaxClass.find_or_create_by_percentage(:percentage => sc['tax_percentage'], 
                                                :name => sc['tax_percentage'])
      
        @shipping_rate.shipping_costs << ShippingCost.create(:weight_min => sc['weight_min'],
                                                              :weight_max => sc['weight_max'],
                                                              :price => BigDecimal(sc['price'].to_s),
                                                              :tax_class => tc
                                                            )
    end    
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
  user.email = 'elvis@elvis.com'
  user.password = '123456'
  user.password_confirmation = '123456'
  user.save

  @cart = Cart.new

  
  table.hashes.each do |prod|
    product = create_product(prod)
    @cart.add_product(product, prod['quantity'])
  end
  @order = Order.new_from_cart(@cart)
  @order.billing_address = billing_address
  @order.user = user
  @order.save
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

Given /^there is a payment method called "([^\"]*)" which is the default$/ do |name|  
  PaymentMethod.create(:name => name, :default => true)
end

Given /^there is a payment method called "([^\"]*)"$/ do |name|  
  PaymentMethod.create(:name => name, :default => false)
end

Given /^the order's payment method is "([^\"]*)"$/ do |name|  
  @order.payment_method = PaymentMethod.find_by_name(name)
  @order.save
end

Given /^the direct shipping fees for shipping rate "([^"]*)" are "([^"]*)" with tax percentage (\d+\.\d+)$/ do |name, amount, percentage|
  sr = ShippingRate.find(:first, :conditions => { :name => name})
  sr.direct_shipping_fees = BigDecimal.new(amount)
  sr.tax_class = TaxClass.find_or_create_by_percentage(:percentage => percentage,
                                               :name => percentage.to_s)
  sr.save
end


When /^I calculate the shipping rate for the order$/ do
  #@order.shipping_rate
end  



