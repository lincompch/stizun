Given /^I have ordered some stuff$/ do
  Given %{a product named "Fish" from supplier "Alltron AG" in the category "Animals"}
  And %{a product named "Terminator T-1000" from supplier "Alltron AG" in the category "Cyborgs"}
  When %{I view the category "Animals"}
  And %{I add the only product in the category "Animals" to my cart 3 times}
  And %{I view the category "Cyborgs"}
  And %{I add the only product in the category "Cyborgs" to my cart 2 times}  
end

Given /^the sales income account is configured$/ do
  ConfigurationItem.create(:name => "sales_income_account_id", :key => "sales_income_account_id", :value => Account.find_by_name("Product Sales"))
end

Given /^the accounts receivable account is configured$/ do
  ConfigurationItem.create(:name => "accounts_receivable_id", :key => "accounts_receivable_id", :value => Account.find_by_name("Accounts Receivable"))
end

When /^I add the store's only product to my cart$/ do
  visit products_path
  fill_in "quantity", :with => 1
  click_button "Kaufen"
end

When /^I add the store's only product to my cart (\d+) times$/ do |num|
  visit products_path
  fill_in "quantity", :with => num
  click_button "Kaufen"
end

When /^I add the only product in the category "([^\"]*)" to my cart (\d+) times$/ do |cat, num|
  num.to_i.times do
    visit products_path
    click_link cat
    fill_in "quantity", :with => 1
    click_button "Kaufen"
  end
end

When /^I visit the checkout$/ do
  visit cart_path
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
  visit cart_path
  page.should have_content(arg1)
end

Then /^my cart should contain a product named "([^\"]*)" (\d+) times$/ do |name, quantity|                                                                     
  visit cart_path
  #page.should have_selector("input", :name => 'cart_line[quantity]', :value => arg2)
  #page.should have_content(arg1)
  all("#cart_table tr").each do |line|
    if line.text =~ /#{name}/
      line.find("td.qty input").value.to_i.should == quantity.to_i
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
#   @email.from.should == "admin@example.com"
#   @email.to.should == @user.email
#   @email.body.should include("some key word or something....")
  
end

