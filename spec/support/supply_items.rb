def create_supply_items
  
  supplier = create_supplier("Alltron AG")
  
  tc = TaxClass.find_or_create_by_percentage(:percentage => 8.0, :name => 8.0)
  
  SupplyItem.create(:name => 'BD-Drive', :purchase_price => 250.0, :weight => 2.0, :tax_class => tc)
  SupplyItem.create(:name => 'CPU', :purchase_price => 50.0, :weight => 4.0, :tax_class => tc)
  return SupplyItem.all
  
end


def create_supplier(name)
  s = Supplier.new
  s.name = name
  sr = ShippingRate.get_default
  s.shipping_rate = sr
  s.save
  return s
end