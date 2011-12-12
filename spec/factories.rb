FactoryGirl.define do

  factory :category do |c|
    c.sequence(:name) {|i| "Category #{i}"}
  end

  factory :product do |p|
    p.sequence(:name) {|i| "Product #{i}"}
    p.description "Some example description"
    p.weight 1.0
    p.association :supplier
    p.association :tax_class
    p.association :supply_item
  end

  factory :supplier do |s|
    s.sequence(:name) {|i| "Supplier #{i}"}
    s.product_base_url "url"
    s.utility_class_name "class"
    s.association :shipping_rate
  end

  factory :supply_item do |s|
    s.sequence(:name) { |i| "SupplyItem#{i}"}
    s.category01 "category1"
    s.category02 "category2"
    s.category03 "category3"
    s.stock 1
    s.association :supplier
    s.association :tax_class
  end

  factory :shipping_rate do |sr|
    sr.sequence(:name) {|i| "Shipping rate #{i}"}
    sr.association :tax_class
  end

  factory :tax_class do |tc|
    tc.sequence(:name) {|i| "Tax class #{i}"}
    tc.percentage 20
  end

  factory :shipping_cost do |sc|
    sc.association :tax_class
    sc.association :shipping_rate
    sc.weight 0
    sc.weight 10
    sc.price 10
  end
  
  factory :margin_range do |mr|
    mr.start_price 0
    mr.end_price 100
    mr.margin_percentage 5.0    
  end

end
