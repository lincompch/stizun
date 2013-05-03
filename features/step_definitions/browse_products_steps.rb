Given /^a category named "([^\"]*)" exists$/ do |arg1|
  @category = Category.find_or_create_by_name(:name => arg1)
end

When /^I view the product list$/ do
  visit products_path
end

When /^I view the category "([^\"]*)"$/ do |category_name|
  visit products_path
  click_link category_name
end

Then /^I should not see a product named "([^\"]*)"$/ do |arg1|
  page.should_not have_content(arg1)
end

Then /^I should see a product named "([^\"]*)"$/ do |arg1|
  page.should have_content(arg1)
end

Then /^there should be a product called "([^\"]*)"$/ do |arg1|
  @prod = Product.where(:name => arg1).first
  @prod.should_not == nil
end

Then /^there should not be a product called "([^\"]*)"$/ do |arg1|
  @prod = Product.where(:name => arg1).first
  @prod.should == nil
end

Then /^the category "([^\"]*)" should contain a product named "([^\"]*)"$/ do |arg1, arg2|
  @cat = Category.find_by_name(arg1)
  @prod = Product.where(:name => arg2).first
  @cat.products.should include @prod
end

When /^I view the product "(.*?)"$/ do |product_name|
  prods = all("tr", :text => product_name)
  prods.first.find("a").click
end

Then /^I should be informed that this laptop is build\-to\-order$/ do
  box = find("#add_to_cart_box")
  box.find(".stock").text.should == "Fertigung in der Schweiz innert 1 - 2 Tagen nach Auftrag"
end

Then /^I should see a stock level of (\d+)$/ do |stock_level|
  box = find("#add_to_cart_box")
  box.find(".stock").text.match(/^#{stock_level}/).should_not == nil
end


