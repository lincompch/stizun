Given /^I have ordered some stuff$/ do
  Given %{a product named "Fish" in the category "Animals"}
  And %{a product named "Terminator T-1000" in the category "Cyborgs"}
  When %{I view the category "Animals"}
  And %{I add the only product in the category "Animals" to my cart 3 times}
  And %{I view the category "Cyborgs"}
  And %{I add the only product in the category "Cyborgs" to my cart 2 times}  
end

When /^I add the store's only product to my cart$/ do
  visit products_path
  fill_in "quantity", :with => 1
  click_button "Add to cart"
end

When /^I add the store's only product to my cart (\d+) times$/ do |num|
  visit products_path
  fill_in "quantity", :with => num
  click_button "Add to cart"
end

When /^I add the only product in the category "([^\"]*)" to my cart (\d+) times$/ do |cat, num|
  num.to_i.times do
    visit products_path
    click_link cat
    fill_in "quantity", :with => 1
    click_button "Add to cart"
  end
end

When /^I visit the checkout$/ do
  visit cart_path
  click_link "Continue to checkout"
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

Then /^my cart should contain a product named "([^\"]*)" (\d+) times$/ do |arg1, arg2|                                                                     
  visit cart_path
  page.should have_selector("input", :name => 'cart_line[quantity]', :value => arg2)
  page.should have_content(" x " + arg1)
end    

Then /^my cart should contain some stuff$/ do                                                         
      Then %{my cart should contain a product named "Fish" 3 times}
      And %{my cart should contain a product named "Terminator T-1000" 2 times}
end    
