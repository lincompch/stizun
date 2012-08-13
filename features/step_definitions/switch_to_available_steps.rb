# coding: utf-8

Angenommen /^ein Produkt "(.*?)" mit Manufacturer Product Code "(.*?)" und Supplier Product Code "(.*?)"$/ do |product_name, manufacturer_product_code, supplier_product_code|

  @product = FactoryGirl.create(:product, :name => product_name, :manufacturer_product_code => manufacturer_product_code, :supplier_product_code => supplier_product_code)
  @product.save.should == true
end

Angenommen /^das Produkt ist verbunden mit dem Supply Item mit Supplier Product Code "(.*?)"$/ do |supplier_product_code|
  @product.supply_item = SupplyItem.where(:supplier_product_code => supplier_product_code).first
  @product.supply_item.should_not == nil
end

Wenn /^das Supply Item "(.*?)" vom Supplier "(.*?)" nicht mehr verfügbar ist$/ do |supplier_product_code, supplier|
  supplier = Supplier.where(:name => supplier).first
  si = supplier.supply_items.where(:supplier_product_code => supplier_product_code).first
  si.status_constant.should == SupplyItem::AVAILABLE
  si.update_attributes(:status_constant => SupplyItem::DELETED).should == true
end

Dann /^ist das Produkt verbunden mit dem Supply Item "(.*?)" von "(.*?)"$/ do |supplier_product_code, supplier_name|
  si = Supplier.where(:name => supplier_name).first.supply_items.where(:supplier_product_code => supplier_product_code).first
  @product.supply_item.should == si

end

Dann /^ist das Produkt nicht verfügbar$/ do
  pending # express the regexp above with the code you wish you had
end

Angenommen /^alle Supply Items sind verfügbar$/ do
  SupplyItem.all.collect(&:status_constant).uniq.should == [SupplyItem::AVAILABLE]

end
