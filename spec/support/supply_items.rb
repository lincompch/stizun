def create_supply_items(supplier, array = [])
  
  items = []  
  tc = TaxClass.find_or_create_by_percentage(:percentage => "8.0", :name => "8.0")
  
  if array.empty?
    items << SupplyItem.create(:supplier => supplier, :name => 'BD-Drive', :purchase_price => "250.0", :weight => 2.0, :tax_class => tc)
    items << SupplyItem.create(:supplier => supplier, :name => 'CPU', :purchase_price => "50.0", :weight => 4.0, :tax_class => tc)
  else
    array.each do |si|
      items << SupplyItem.create(:supplier => supplier,
                        :name => si['name'], 
                        :purchase_price => si['purchase_price'], 
                        :weight => si['weight'], 
                        :tax_class => TaxClass.find_by_percentage(si['tax_percentage']))
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
  attributes.each do |k,v|
    si.send(k).should == v
  end
end

def supply_items_should_be_marked_deleted(ids, supplier)
  SupplyItem.where(:id => ids, :supplier_id => supplier).collect(&:status_constant).uniq.first.should == SupplyItem::DELETED
end
