
Then /^the following supply items should exist:$/ do |table|
  table.hashes.each do |s|
    si = SupplyItem.find(:all, :conditions => { :supplier_product_code => s['product_code'] })
    si.count.should == 1
    si.first.stock.should == s['stock'].to_i
    si.first.supplier_product_code.should == s['product_code']
    si.first.purchase_price.should == BigDecimal.new(s['price'].to_s)
    si.first.weight.should == s['weight'].to_f
  end
end

Then /^the following supply items should not exist:$/ do |table|
 table.hashes.each do |s|
   si = SupplyItem.find(:first, :conditions => {:supplier_product_code => s['product_code']})
   si.should == nil
 end
end

Given /^there are the following supply items:$/ do |table|
  
  table.hashes.each do |s|
    si = SupplyItem.new
    si.supplier = Supplier.where(:name => s['supplier']).first
    si.supplier_product_code = s['product_code']
    si.name = s['name']
    si.stock = s['stock']
    si.supplier_product_code = s['product_code']
    si.purchase_price = BigDecimal.new(s['price'].to_s)
    si.weight = s['weight'].to_f
    si.save
  end
end
