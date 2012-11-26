
Given 'the Sphinx indexes are updated' do
  # Update all indexes
  ThinkingSphinx::Test.index
  sleep(0.25) # Wait for Sphinx to catch up
end


When /^I wait for a fancybox to appear$/ do
  page.has_css?("#fancybox-frame", :visible => true)
end


When /^I create a product called "([^\"]*)"$/ do |arg1|
 visit admin_products_path
 create_link = all("a", :text => 'Create new product').first
 create_link.click
 within_frame "fancybox-frame" do
   fill_in "Name", :with => arg1
 end 
end

When /^I fill in "([^"]*)" in the CKEditor instance "([^"]*)"$/ do |value, input_id|
  within_frame "fancybox-frame" do
    browser = page.driver.browser
    browser.execute_script("CKEDITOR.instances['#{input_id}'].setData('#{value}');")
  end
end

When /^fill in the product description "([^\"]*)"$/ do |arg1|
 within_frame "fancybox-frame" do
#   click_link "Toggle WYSIWYG editor"
   fill_in "product_description", :with => arg1
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
    candidate = all(".buttonbar input").first
    candidate.click if candidate.value == "Create new product"
  end
end

When /^I assign the product to the category "([^\"]*)"$/ do |arg1|
  within_frame "fancybox-frame" do
    select arg1, :from => "Categories"
  end
end


Then /^(?:|I )should see "([^"]*)" in the fancybox$/ do |text|
  within_frame "fancybox-frame" do
    page.should have_content(text)
  end
end


Then /^I should see an error message inside the fancybox$/ do
  within_frame "fancybox-frame" do
    page.has_css?("#errorExplanation", :visible => true).should == true
  end
end

