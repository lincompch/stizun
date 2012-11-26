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
  end

  factory :product do
    sequence(:name) {|i| "Product #{i}"}
    description "Some example description"
    weight 1.0
    purchase_price "100.0"
    sequence(:manufacturer_product_code) {|i| "MFG#{i}"}
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
  
  factory :category_dispatcher do
    level_01 "Foo"
    level_02 "Bar"
    level_03 "Baz"
  end
end
