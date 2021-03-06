
Given /^I am logged in as "([^\"]*)"$/ do |username|
  # TODO: Factory
  user = User.create(:email => username, :password => "foobarbar", :password_confirmation => "foobarbar")
  user.save.should == true
  visit "/users/sign_in"
  fill_in "user[email]", :with => username
  fill_in "user[password]", :with => "foobarbar"
  click_button "Einloggen"
end

When /^I view my personal order list$/ do
  visit "/users/me"
  first("a", :text => "Bestellungen").click
end

Then /^I should see (\d+) order(s)?$/ do |count, foo|
  all("div.order").count.should == count.to_i
end

When /^I view the invoice for order number (\d+)$/ do |num|
  all("div.order")[num.to_i - 1].find("a", :text => 'Rechnung ansehen').click
end

When /^my eyes stick to order number (\d+)$/ do |num|
  @order_container = all("div.order")[num.to_i - 1]
end

Then /^the order should show a grand total of (\d+)\.(\d+)$/ do |arg1, arg2|
  amount = (arg1.to_s + "." + arg2.to_s).to_f
  @order_container.find(".taxed_price").text.strip.to_f.should == amount
end

Then /^the order should show a shipping cost including VAT of (\d+)\.(\d+)$/ do |arg1, arg2|
  amount = (arg1.to_s + "." + arg2.to_s).to_f
  @order_container.find(".shipping_cost_including_taxes").text.strip.to_f.should == amount
end

When "I view the order's invoice" do
  @order_container.find("a", :text => 'Rechnung ansehen').click
end

When /^I view my personal invoice list$/ do
  visit "/users/me"
  click_link "Rechnungen"
end

Then /^the invoice should show a total excluding VAT of (\d+)\.(\d+)$/ do |arg1, arg2|
  amount = (arg1.to_s + "." + arg2.to_s).to_f
  find("#invoice_products_price").text.strip.to_f.should == amount
end

Then /^the invoice should show a total VAT of (\d+)\.(\d+)$/ do |arg1, arg2|
  amount = (arg1.to_s + "." + arg2.to_s).to_f
  find("#invoice_taxes").text.strip.to_f.should == amount
end

Then /^the invoice should show a product total including VAT of (\d+)\.(\d+)$/ do |arg1, arg2|
  amount = (arg1.to_s + "." + arg2.to_s).to_f
  find("#invoice_products_taxed_price").text.strip.to_f.should == amount
end

Then /^the invoice should show a grand total of (\d+)\.(\d+)$/ do |arg1, arg2|
  amount = (arg1.to_s + "." + arg2.to_s).to_f
  find("#invoice_taxed_price").text.strip.to_f.should == amount
end

Then /^the invoice should show a shipping cost including VAT of (\d+)\.(\d+)$/ do |arg1, arg2|
  amount = (arg1.to_s + "." + arg2.to_s).to_f
  find("#invoice_shipping_cost_including_taxes").text.strip.to_f.should == amount
end



Given /^I have ordered some stuff$/ do
  create_product({'name' => 'Fish', 'category' => 'Animals', 'supplier' => 'Alltron AG', 'purchase_price' => 100.0})
  create_product({'name' => 'Terminator T-1000', 'category' => 'Cyborgs', 'supplier' => 'Alltron AG', 'purchase_price' => 100.0})
  And %{I view the category "Animals"}
  And %{I add the product called "Fish" to my cart 3 times}
  And %{I view the category "Cyborgs"}
  And %{I add the product called "Terminator T-1000" to my cart 2 times}
end

Given /^the sales income account is configured$/ do
  ConfigurationItem.create(:name => "sales_income_account_id", :key => "sales_income_account_id", :value => Account.find_by_name("Product Sales"))
end

Given /^the accounts receivable account is configured$/ do
  ConfigurationItem.create(:name => "accounts_receivable_id", :key => "accounts_receivable_id", :value => Account.find_by_name("Accounts Receivable"))
end


When /^I add the product "([^\"]*)" to my cart (\d+) times$/ do |name, num|
  # TODO: Optimize and clean up this horrible mess
  row = find("table.productlist tr", :text => name)
  if row
    within row do
      fill_in "quantity", :with => num
      click_button "Kaufen"
    end
  else
    raise "No row found for product #{name}"
  end

end


When /^I visit the checkout$/ do
  visit root_path 
  click_link "Weiter zur Kasse"
end

When /^I submit my order$/ do
  click_button "Bestellung aufgeben"
end

Then /^I should see an order summary$/ do
  # TODO: Right now we check for the German (Switzerland) text because that's the
  # default locale. In future, the default locale should be en_UK and we should check
  # both for that and for the German one, plus whether switching between the two works.
  page.should have_content("Zusammenfassung Ihrer Bestellung")
end

Then /^my cart should contain a product named "([^\"]*)"$/ do |arg1|
  visit root_path
  page.should have_content(arg1)
end

Then /^my cart should contain a product named "([^\"]*)" (\d+) times$/ do |name, quantity|
  visit cart_path
  #page.should have_selector("input", :name => 'cart_line[quantity]', :value => arg2)
  #page.should have_content(arg1)
  all("#sidebar_cart tr").each do |line|
    if line.text =~ /#{name}/
      line.find("input").value.to_i.should == quantity.to_i
    end
  end

end

Then /^my cart should contain some stuff$/ do
  Then %{my cart should contain a product named "Fish" 3 times}
  And %{my cart should contain a product named "Terminator T-1000" 2 times}
end

Then /^I should receive (\d+) e\-mails$/ do |num|
  @emails = ActionMailer::Base.deliveries
  @emails.count.should == num.to_i
end

Then /^the subject of e\-mail (\d+) should be "([^"]*)"$/ do |num, subject|
  # Adjust for human-readable numbers instead of index
  # positions used in the .feature text
  index = num.to_i - 1
  @emails[index].subject.should == subject
end


Then /^the order summary should contain a total excluding VAT of (\d+)\.(\d+)$/ do |arg1, arg2|
  amount = (arg1.to_s + "." + arg2.to_s).to_f
  find("#document_gross_price").text.strip.to_f.should == amount
end

Then /^the order summary should contain a product VAT of (\d+)\.(\d+)$/ do |arg1, arg2|
  amount = (arg1.to_s + "." + arg2.to_s).to_f
  find("#document_taxes").text.strip.to_f.should == amount
end

Then /^the order summary should contain a product total including VAT of (\d+)\.(\d+)$/ do |arg1, arg2|
  amount = (arg1.to_s + "." + arg2.to_s).to_f
  find("#document_products_taxed_price").text.strip.to_f.should == amount
end

Then /^the order summary should contain shipping cost including VAT of (\d+)\.(\d+)$/ do |arg1, arg2|
  amount = (arg1.to_s + "." + arg2.to_s).to_f
  find("#document_shipping_cost_including_taxes").text.strip.to_f.should == amount
end

Then /^the order summary should contain a grand total of (\d+)\.(\d+)$/ do |arg1, arg2|
  amount = (arg1.to_s + "." + arg2.to_s).to_f
  find("#document_taxed_price").text.strip.to_f.should == amount
end

Then /^the order summary should contain a total VAT of (\d+)\.(\d+)$/ do |arg1, arg2|
  amount = (arg1.to_s + "." + arg2.to_s).to_f
  find("#document_total_taxes").text.strip.to_f.should == amount
end

Then /^I should see an invoice$/ do
  all("h2").first.text.should =~ /.*Rechnung.*/
end


Given /^the latest order has an estimated delivery date of "([^"]*)"$/ do |date_string|
  o = Order.last
  o.estimated_delivery_date =  Date.strptime("#{date_string}", "%d.%m.%Y")
  o.save
end

Given /^the latest order has a status of "([^"]*)"$/ do |status_string|
  o = Order.last
  o.status_constant =  status_string.constantize
  o.save
end

Then /^I should see the latest order under the heading for orders that are processing$/ do
  o = Order.last
  did = o.document_id
  page.should have_selector("#orders_in_processing_or_ready_to_ship div.orders div.order")
  order_block = find("#orders_in_processing_or_ready_to_ship").find(".order").text.should =~ /.*#{did}.*/
end

Then /^the order should show up as "([^"]*)"$/ do |status_string|
  order_block = find("#orders_in_processing_or_ready_to_ship").find(".order").text.should =~ /.*Status: #{status_string}.*/
end



