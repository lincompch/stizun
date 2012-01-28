Given /^there is a default shipping calculator of type ShippingCalculatorBasedOnWeight called "([^\"]*)" with the following costs:$/ do |name, table|  
  
  tax_class = TaxClass.find_or_create_by_percentage(:percentage => 8.0, :name => "8.0%")
  @shipping_calculator = ShippingCalculatorBasedOnWeight.create(:name => name, :tax_class => tax_class)
  
  # Only create and assign new costs if we don't have any yet on this 
  # @shipping_calculator. Otherwise, leave stuff alone.
  if @shipping_calculator.configuration.shipping_costs.blank?
    table.hashes.each do |sc|
        @shipping_calculator.configuration.shipping_costs = []
        @shipping_calculator.configuration.shipping_costs << {:weight_min => sc['weight_min'].to_i,
                                                              :weight_max => sc['weight_max'].to_i,
                                                              :price => BigDecimal(sc['price'].to_s)}
    end
    if @shipping_calculator.save    
      ConfigurationItem.create(:key => 'default_shipping_calculator_id', :value => @shipping_calculator.id)
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





