# coding: utf-8

Angenommen /^ein Produkt "(.*?)" mit Manufacturer Product Code "(.*?)" und Supplier Product Code "(.*?)"$/ do |product_name, manufacturer_product_code, supplier_product_code|

  @product = FactoryGirl.create(:product, :name => product_name, :manufacturer_product_code => manufacturer_product_code, :supplier_product_code => supplier_product_code)
  @product.save.should == true
end

Angenommen /^das Produkt ist verbunden mit dem Supply Item mit Supplier Product Code "(.*?)"$/ do |supplier_product_code|
  @product.supply_item = SupplyItem.where(:supplier_product_code => supplier_product_code).first
  @product.save  
  @product.reload.supply_item.should_not == nil
end

Wenn /^das Supply Item "(.*?)" vom Supplier "(.*?)" nicht mehr verfügbar ist$/ do |supplier_product_code, supplier|
  supplier = Supplier.where(:name => supplier).first
  si = supplier.supply_items.where(:supplier_product_code => supplier_product_code).first
  si.status_constant.should == SupplyItem::AVAILABLE
  si.status_constant = SupplyItem::DELETED
  si.save.should == true
  si.reload.status_constant.should == SupplyItem::DELETED
  Product.update_price_and_stock
end

Dann /^ist das Produkt verbunden mit dem Supply Item "(.*?)" von "(.*?)"$/ do |supplier_product_code, supplier_name|
  si = Supplier.where(:name => supplier_name).first.supply_items.where(:supplier_product_code => supplier_product_code).first
  @product.reload.supply_item.should == si
end

Dann /^ist das Produkt nicht verfügbar$/ do
  @product.reload.available?.should == false
end

Angenommen /^alle Supply Items sind verfügbar$/ do
  SupplyItem.all.collect(&:status_constant).uniq.should == [SupplyItem::AVAILABLE]

end


Wenn /^der Supplier "(.*?)" (\d+) Stück vom Supply Item "(.*?)" an Lager hat$/ do |supplier_name, stock, supplier_product_code|
  si = Supplier.where(:name => supplier_name).first.supply_items.where(:supplier_product_code => supplier_product_code).first
  si.stock = stock.to_i
  si.save
  si.reload.stock.should == stock.to_i
  Product.update_price_and_stock
end


Wenn /^es günstigere Supply Items für das Produkt gibt$/ do
  @product.cheaper_supply_item_available?.should == true
end

Wenn /^dessen Supplier (\d+) Stück des günstigsten Supply Items an Lager hat$/ do |count|
  @supply_item = @product.cheaper_supply_items.first
  @supply_item.stock = count.to_i
  @supply_item.save.should == true
end

Wenn /^der Supplier (\d+) Stück dieses Supply Items an Lager hat$/ do |count|
  @supply_item.stock = count.to_i
  @supply_item.save.should == true
end

Dann /^ist dieses Supply Item der beste Kandidat für einen automatischen Wechsel$/ do
  @product.cheaper_supply_items.first.should == @supply_item
end

Dann /^ist dieses Supply Item nicht der beste Kandidat für einen automatischen Wechsel$/ do
  @product.cheaper_supply_items.first.should_not == @supply_item
end

