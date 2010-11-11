When /^I import the file "([^"]*)"$/ do |filename|
  pending # express the regexp above with the code you wish you had
end

Then /^there are (\d+) products in the database$/ do |num|
  Product.all.count.should == num
end

Then /^the following supply items exist:$/ do |table|
  
  table.hashes.each do |s|
    si = SupplyItem.find(:first, :conditions => {
                      :manufacturer_product_code => s['product_code'],
                      :price => s['price'],
                      :weight => s['weight'],
                      :stock => s['stock']}
                   )
    si.count.should == 1
  end
  
end
