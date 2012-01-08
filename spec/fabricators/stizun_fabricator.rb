
Fabricator(:category) do |c|
  name { sequence(:name) {|i| "Category #{i}"} }
end

Fabricator(:product) do |p|
  name { sequence(:name) {|i| "Product #{i}"} }
  p.description "Some example description"
  p.weight 1.0
  p.purchase_price 100.0
  supplier
  tax_class
  supply_item
end

Fabricator(:supplier) do |s|
  name { sequence(:name) {|i| "Supplier #{i}"} }
  s.product_base_url "url"
  s.utility_class_name "class"
  shipping_rate
end

Fabricator(:supply_item) do
  name { sequence(:name) { |i| "SupplyItem#{i}"} }
  category01 "category1"
  category02 "category2"
  category03 "category3"
  stock 1
  supplier
  tax_class
end

Fabricator(:shipping_rate) do
  name { sequence(:name) {|i| "Shipping rate #{i}"} }
  tax_class
end

Fabricator(:tax_class) do
  name { sequence(:name) {|i| "Tax class #{i}"} }
  percentage 20
end

Fabricator(:shipping_cost) do
  tax_class
  shipping_rate
  weight_min 0
  weight_max 10000
  price 10
end

Fabricator(:margin_range) do
  start_price 0
  end_price 100
  margin_percentage 5.0    
end

Fabricator(:country) do
  name "Somewhereland"
end

Fabricator(:address) do |a|
  firstname "Foo"
  lastname "Bar"
  street { sequence(:street) {|i| "Some Street No. #{i}"} }
  postalcode { sequence(:postalcode) {|i| "#{i}"} }
  city "The Bay of No Hope"
  email "foo@bar.com"
  country
end

