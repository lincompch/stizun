Given /^the following products exist:$/ do |table|
  table.hashes.each do |prod|
    product = create_product(prod)
 end
end