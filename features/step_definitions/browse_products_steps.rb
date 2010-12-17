Given /^a category named "([^\"]*)" exists$/ do |arg1|
  @category = Category.create(:name => arg1)
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

When /^I wait for a fancybox to appear$/ do
  page.has_css?("#fancybox-frame", :visible => true)
end


When /^I create a product called "([^\"]*)"$/ do |arg1|
 visit admin_products_path
 click_link "Create new product"
 
 within_frame "fancybox-frame" do
   fill_in "Name", :with => arg1
 end
 
end

When /^fill in the product description "([^\"]*)"$/ do |arg1|
 within_frame "fancybox-frame" do
   fill_in "Description", :with => arg1
 end
end

When /^I fill in the purchase price (\d+\.\d+)$/ do |arg1|
  within_frame "fancybox-frame" do
    fill_in "Purchase price", :with => arg1
  end
end

When /^I fill in the margin percentage (\d+\.\d+)$/ do |arg1|
  within_frame "fancybox-frame" do
    fill_in "Profit margin (in percent)", :with => arg1
  end
end

When /^I fill in the weight (\d+\.\d+)$/ do |arg1|
  within_frame "fancybox-frame" do
    fill_in "Weight", :with => arg1
  end
end

When /^I select the tax class "([^\"]*)"$/ do |arg1|
  within_frame "fancybox-frame" do
    select arg1, :from => "Tax Class"
  end
end

When /^I select the supplier "([^\"]*)"$/ do |arg1|
  within_frame "fancybox-frame" do
    select arg1, :from => "Supplier"
  end
end

When /^I click the create button$/ do
  within_frame "fancybox-frame" do
    click_button "Create"
  end
end

When /^I assign the product to the category "([^\"]*)"$/ do |arg1|
  within_frame "fancybox-frame" do
    select arg1, :from => "Categories"
  end
end
                                                                                          
When /^I view the product list$/ do                                                       
  visit products_path                 
end 

When /^I view the category "([^\"]*)"$/ do |arg1|                                                                                                
  visit products_path
  click_link arg1
end 

Then /^(?:|I )should see "([^"]*)" within the fancybox$/ do |text|
  within_frame "fancybox-frame" do
    page.should have_content(text)
  end
end

Then /^I should not see a product named "([^\"]*)"$/ do |arg1|                                                                                   
  page.should_not have_content(arg1)                                                                    
end    

Then /^I should see a product named "([^\"]*)"$/ do |arg1|                                
  page.should have_content(arg1)                   
end  

Then /^there should be a product called "([^\"]*)"$/ do |arg1|
  @prod = Product.find(:first, :conditions => {:name => arg1})
  @prod.should_not == nil
end

Then /^there should not be a product called "([^\"]*)"$/ do |arg1|
  @prod = Product.find(:first, :conditions => {:name => arg1})
  @prod.should == nil
end

Then /^the category "([^\"]*)" should contain a product named "([^\"]*)"$/ do |arg1, arg2|
  @cat = Category.find_by_name(arg1)
  @prod = Product.find(:first, :conditions => {:name => arg2})
  @cat.products.should include @prod
end

Then /^I should see an error message inside the fancybox$/ do
  within_frame "fancybox-frame" do
    page.has_css?("#errorExplanation", :visible => true).should == true
  end
end

