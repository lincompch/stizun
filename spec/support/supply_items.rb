def create_supply_items(supplier, array = [])
  
  items = []  
  tc = TaxClass.find_or_create_by(:percentage => "8.0", :name => "8.0")
  
  if array.empty?
    items << SupplyItem.create(:supplier => supplier, :name => 'BD-Drive', :purchase_price => "250.0", :weight => 2.0)
    items << SupplyItem.create(:supplier => supplier, :name => 'CPU', :purchase_price => "50.0", :weight => 4.0)
  else
    array.each do |si|
      items << SupplyItem.create(:supplier => supplier,
                        :name => si['name'], 
                        :purchase_price => si['purchase_price'], 
                        :weight => si['weight'])
    end
  
  end
  
  
  return items
  
end


def create_supplier(name)
  s = Supplier.new
  s.name = name
  s.save
  return s
end

def supply_item_should_be(supplier, supplier_product_code, attributes = {})
  si = supplier.supply_items.where(:supplier_product_code => supplier_product_code).first
  expect(si).to_not be_nil
  attributes.each do |k,v|
    expect(si.send(k)).to eq(v)
  end
end

def supply_items_should_be_marked_deleted(ids, supplier)
  expect(SupplyItem.where(:id => ids, :supplier_id => supplier).collect(&:status_constant).uniq.first).to eq(SupplyItem::DELETED)
end
