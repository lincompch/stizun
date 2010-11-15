When /^I import the file "([^"]*)"$/ do |filename|
  AlltronUtil.import_supply_items(RAILS_ROOT + "/" + filename)
end

When /^I destroy all supply items$/ do
  SupplyItem.destroy_all
end

Then /^there are (\d+) supply items in the database$/ do |num|
  SupplyItem.all.count.should == num.to_i
end

Then /^the following supply items exist:$/ do |table|
  
  table.hashes.each do |s|
    si = SupplyItem.find(:all, :conditions => { :supplier_product_code => s['product_code'] })
    si.count.should == 1
    si.first.supplier_product_code.should == s['product_code']
    si.first.purchase_price.should == BigDecimal.new(s['price'].to_s)
    si.first.weight.should == s['weight'].to_f
  end
  
end

Then /^the following supply items do not exist:$/ do |table|
 table.hashes.each do |s|
   si = SupplyItem.find(:first, :conditions => {:supplier_product_code => s['product_code']})
   si.should == nil
 end
end
