Given /^a category named "([^\"]*)"$/ do |arg1|
  @category = Category.new
  @category.name = arg1
  @category.save
end

Given /^a product named "([^\"]*)"$/ do |arg1| 
  @product = Product.new
  @product.name = arg1
  @product.description = "Blah"
  @product.weight = 5.0
  @product.tax_class = TaxClass.find_or_create_by_name_and_percentage("Foo", 2.5)
  @product.save
end

Given /^a product named "([^\"]*)" in the category "([^\"]*)"$/ do |arg1, arg2|           
  @product = Product.new
  @product.name = arg1
  @product.description = "Blah"
  @product.weight = 5.0
  @product.tax_class = TaxClass.find_or_create_by_name_and_percentage("Foo", 2.5)

  @category = Category.new
  @category.name = arg2
  @category.save
  
  @category.products << @product
  @product.save

end                                   


When /^I create a product called "([^\"]*)"$/ do |arg1|
 pending
 # cannot do this because creating products is now in a fancybox and
 # webrat can't do javascript
 # visit admin_products_path
 # click_link "Create new product"
 # fill_in "Name", :with => arg1
end

When /^fill in the product description "([^\"]*)"$/ do |arg1|
   pending
 # cannot do this because creating products is now in a fancybox and
 # webrat can't do javascript
 # fill_in "Description", :with => arg1
end

When /^I fill in the purchase price (\d+\.\d+)$/ do |arg1|
 pending
 # cannot do this because creating products is now in a fancybox and
 # webrat can't do javascript
#   fill_in "Purchase price", :with => arg1
end

When /^I fill in the margin percentage (\d+\.\d+)$/ do |arg1|
   pending
 # cannot do this because creating products is now in a fancybox and
 # webrat can't do javascript
#   fill_in "Profit margin (in percent)", :with => arg1
end

When /^I fill in the weight (\d+\.\d+)$/ do |arg1|
   pending
 # cannot do this because creating products is now in a fancybox and
 # webrat can't do javascript
#   fill_in "Weight", :with => arg1
end

When /^I select the tax class "([^\"]*)"$/ do |arg1|
   pending
 # cannot do this because creating products is now in a fancybox and
 # webrat can't do javascript
#   select arg1, :from => "Tax Class"
end

When /^I click the create button$/ do
   pending
 # cannot do this because creating products is now in a fancybox and
 # webrat can't do javascript
#   click_button "Create"
end

When /^I assign the product to the category "([^\"]*)"$/ do |arg1|
  pending
#   visit edit_admin_product_path(@product)
#   select arg1, :from => "Categories"
#   click_button "Save"
end
                                                                                          
When /^I view the product list$/ do                                                       
  visit products_path                 
end 

When /^I view the category "([^\"]*)"$/ do |arg1|                                                                                                
  visit products_path
  click_link arg1
end 

Then /^I should not see a product named "([^\"]*)"$/ do |arg1|                                                                                   
  response.should_not contain(arg1)                                                                    
end    

Then /^I should see a product named "([^\"]*)"$/ do |arg1|                                
  response.should contain(arg1)                   
end  

Then /^there should be a product called "([^\"]*)"$/ do |arg1|
  @prod = Product.find_by_name(arg1)
  @prod.should_not == nil
end

Then /^the category "([^\"]*)" should contain a product named "([^\"]*)"$/ do |arg1, arg2|
  @cat = Category.find_by_name(arg1)
  @prod = Product.find_by_name(arg2)
  @cat.products.should include @prod
end

Then /^I should see an error message$/ do
  regexp = Regexp.new(/error(s)? prohibited/)
  response.should contain(regexp)
end

