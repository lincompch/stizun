
Fabricator(:category) do |c|
  name { sequence(:name) {|i| "Category #{i}"} }
end

Fabricator(:tax_class) do
  name { sequence(:name) {|i| "Tax class #{i}"} }
  percentage 20
end


Fabricator(:supplier) do
  name { sequence(:name) {|i| "Supplier #{i}"} }
  product_base_url "url"
  utility_class_name "class"
end

Fabricator(:alltron, :from => :supplier) do
  name "Alltron AG"
end


Fabricator(:supply_item) do
  name { sequence(:name) { |i| "SupplyItem#{i}"} }
  category01 "category1"
  category02 "category2"
  category03 "category3"
  stock 1
  supplier! { Fabricate(:supplier) }
  tax_class! { Fabricate(:tax_class) }
end

Fabricator(:product) do |p|
  name { sequence(:name) {|i| "Product #{i}"} }
  p.description "Some example description"
  p.weight 1.0
  p.purchase_price 100.0
  supplier! { Fabricate(:supplier) }
  tax_class! { Fabricate(:tax_class) }
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

