Factory.define :category do |c|
  c.sequence(:name) {|i| "Category #{i}"}
end

Factory.define :product do |p|
  p.sequence(:name) {|i| "Product #{i}"}
  p.description "Some example description"
  p.weight 1.0
  p.association :supplier
  p.association :tax_class
end

Factory.define :supplier do |s|
  s.sequence(:name) {|i| "Supplier #{i}"}
  s.product_base_url "url"
  s.utility_class_name "class"
  s.association :shipping_rate
end

Factory.define :shipping_rate do |sr|
  sr.sequence(:name) {|i| "Shipping rate #{i}"}
  sr.association :tax_class
end

Factory.define :tax_class do |tc|
  tc.sequence(:name) {|i| "Tax class #{i}"}
  tc.percentage 20
end

Factory.define :shipping_cost do |sc|
  sc.association :tax_class
  sc.association :shipping_rate
  sc.weight 0
  sc.weight 10
  sc.price 10
end

