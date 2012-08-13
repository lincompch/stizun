
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

Given /^there are the following supply items:|es gibt folgende Supply Items:$/ do |table|
  table.hashes.each do |s|
    supplier = Supplier.where(:name => s['supplier']).first
    supplier = FactoryGirl.create(:supplier, :name => s['supplier'])
    si = SupplyItem.new
    si.supplier = supplier
    si.name = s['name']
    si.stock = s['stock']
    si.supplier_product_code = s['product_code']
    si.manufacturer_product_code = s['manufacturer_product_code']
    si.purchase_price = BigDecimal.new(s['price'].to_s)
    si.weight = s['weight'].to_f
    binding.pry
    si.save.should == true 
  end
end
