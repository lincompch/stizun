Given /^an order with a few items$/ do
  c = Cart.new

  p = Product.first
  p.purchase_price = 100.0
  p.save
  c.add_product(p)

  p = Product.last
  p.purchase_price = 120.0
  p.save
  c.add_product(p)

  @order = Order.new_from_cart(c)
  @order.billing_address = FactoryGirl.create(:address, :firstname => 'Minimal First', :lastname => 'Minimal Last', :city => 'Minimal City', :country => Country.first)
  @order.save.should == true

end

Given /^an invoice for that order$/ do
  @invoice = Invoice.create_from_order(@order)
  @invoice.save.should == true
end

When /^I am logged in as an admin$/ do
  step 'there is a user with e-mail address "admin@something.com" and password "foobar"'
  step 'the user group "Admins" exists'
  step 'the user group "Admins" has admin permissions'
  step 'the user is member of the group "Admins"'
  step 'I log in with e-mail address "admin@something.com" and password "foobar"'
end

When /^I am in the admin area$/ do
  visit "/admin"
end

When /^I go to the invoice area$/ do
  click "Invoices"
end

When /^I search for some text from that invoice$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I see a list of invoices$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^that invoice is part of the list$/ do
  pending # express the regexp above with the code you wish you had
end
