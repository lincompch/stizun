# FactoryGirl.define do
# 
#   factory :category do |c|
#     c.sequence(:name) {|i| "Category #{i}"}
#   end
# 
#   factory :product do |p|
#     p.sequence(:name) {|i| "Product #{i}"}
#     p.description "Some example description"
#     p.weight 1.0
#     p.purchase_price 100.0
#     p.association :supplier
#     p.association :tax_class
#     p.association :supply_item
#   end
# 
#   factory :supplier do |s|
#     s.sequence(:name) {|i| "Supplier #{i}"}
#     s.product_base_url "url"
#     s.utility_class_name "class"
#     s.association :shipping_rate
#   end
# 
#   factory :supply_item do |s|
#     s.sequence(:name) { |i| "SupplyItem#{i}"}
#     s.category01 "category1"
#     s.category02 "category2"
#     s.category03 "category3"
#     s.stock 1
#     s.association :supplier
#     s.association :tax_class
#   end
# 
#   factory :shipping_rate do |sr|
#     sr.sequence(:name) {|i| "Shipping rate #{i}"}
#     sr.association :tax_class
#   end
# 
#   factory :tax_class do |tc|
#     tc.sequence(:name) {|i| "Tax class #{i}"}
#     tc.percentage 20
#   end
# 
#   factory :shipping_cost do |sc|
#     sc.association :tax_class
#     sc.association :shipping_rate
#     sc.weight_min 0
#     sc.weight_max 10000
#     sc.price 10
#   end
#   
#   factory :margin_range do |mr|
#     mr.start_price 0
#     mr.end_price 100
#     mr.margin_percentage 5.0    
#   end
#   
#   factory :country do |c|
#     c.name "Somewhereland"
#   end
#   
#   factory :address do |a|
#     a.firstname "Foo"
#     a.lastname "Bar"
#     a.sequence(:street) {|i| "Some Street No. #{i}"}
#     a.sequence(:postalcode) {|i| "#{i}"}
#     a.city "The Bay of No Hope"
#     a.email "foo@bar.com"
#     association :country
#   end
#   
# end




FactoryGirl.define do

	factory :category do |c|
	  sequence(:name) {|i| "Category #{i}"}
	end


	factory :supplier do
	  sequence(:name) {|i| "Supplier #{i}"}
	  product_base_url "url"
	  utility_class_name "class"
	end

	factory :alltron, :class => Supplier  do
	  name "Alltron AG"
	end

	factory :tax_class do
	  sequence(:name) {|i| "Tax class #{i}" }
	  percentage "20"
	end

	factory :supply_item do
	  sequence(:name) { |i| "SupplyItem#{i}"}
	  category01 "category1"
	  category02 "category2"
	  category03 "category3"
	  stock 1
	  association :supplier
	  association :tax_class
	end

	factory :product do
	  sequence(:name) {|i| "Product #{i}"}
	  description "Some example description"
	  weight 1.0
	  purchase_price "100.0"
	  association :supplier
	  association :tax_class
	end

	factory :margin_range do
	  start_price 0
	  end_price 100
	  margin_percentage 5.0    
	end

	factory :country do
	  name "Somewhereland"
	end

	factory :address do |a|
	  firstname "Foo"
	  lastname "Bar"
	  sequence(:street) {|i| "Some Street No. #{i}"}
	  sequence(:postalcode) {|i| "#{i}"}
	  city "The Bay of No Hope"
	  email "foo@bar.com"
	  association :country
	end

end