Given /^the following products exist\(table\):$/ do |table|
  table.hashes.each do |prod|
    product = create_product(prod)
 end
end

Then "I see the following featured products:" do |table|
  table.hashes.each do |prod|
    find("#featured_products").text.should =~ /.*#{prod['name']}.*/
  end
end

When /^I check #{capture_model}'s first checkbox$/ do |model_name|
  model = model!(model_name)
  check("product_id_#{model.id}")
end

Then /^category: "([^"]*)" should contain product: "([^"]*)"$/ do |category, product|
  category = Category.find_by_name(category)
  product = Product.find_by_name(product)
  category.products.should include(product)
end

