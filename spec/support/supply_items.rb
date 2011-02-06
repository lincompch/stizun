def create_supply_items(supplier, array = [])
  
  supplier ||= create_supplier("Alltron AG")
  
  tc = TaxClass.find_or_create_by_percentage(:percentage => 8.0, :name => 8.0)
  
  if array.empty?
    SupplyItem.create(:supplier => supplier, :name => 'BD-Drive', :purchase_price => 250.0, :weight => 2.0, :tax_class => tc)
    SupplyItem.create(:supplier => supplier, :name => 'CPU', :purchase_price => 50.0, :weight => 4.0, :tax_class => tc)
  else
    array.each do |si|
      SupplyItem.create(:supplier => supplier,
                        :name => si['name'], 
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

# def supply_item_should_be(supplier, supplier_product_code, weight, purchase_price, stock)        
#   si = SupplyItem.where(:supplier_id => supplier, :supplier_product_code => supplier_product_code).first
#   si.weight.should == weight
#   si.purchase_price.should == purchase_price
#   si.stock.should == stock
# end

def supply_item_should_be(supplier, supplier_product_code, attributes = {})
  puts "________________", "searching for #{supplier_product_code} from #{supplier}","______"
  si = SupplyItem.where(:supplier_id => supplier, :supplier_product_code => supplier_product_code).first
  attributes.each do |k,v|
    si.send(k).should == v
  end
end



def supply_items_should_be_marked_deleted(ids, supplier)
  SupplyItem.where(:id => ids, :supplier_id => supplier).collect(&:status_constant).uniq.first.should == SupplyItem::DELETED
end