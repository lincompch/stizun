def create_supply_items(array = [])
  
  supplier = create_supplier("Alltron AG")
  
  tc = TaxClass.find_or_create_by_percentage(:percentage => 8.0, :name => 8.0)
  
  if array.empty?
    SupplyItem.create(:name => 'BD-Drive', :purchase_price => 250.0, :weight => 2.0, :tax_class => tc)
    SupplyItem.create(:name => 'CPU', :purchase_price => 50.0, :weight => 4.0, :tax_class => tc)
  else
    array.each do |si|
      SupplyItem.create(:name => si['name'], 
                        :purchase_price => si['purchase_price'], 
                        :weight => si['weight'], 
                        :tax_class => TaxClass.find_by_percentage(si['tax_percentage']))
    end
  
  end
  
  
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