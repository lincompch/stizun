require 'spec_helper'


describe ShippingCalculator do
  
end

describe ShippingCalculatorBasedOnWeight do

  before(:all) do
    @sc = ShippingCalculatorBasedOnWeight.create(:name => 'For Testing')
    @sc.configuration.shipping_costs = []
    @sc.configuration.shipping_costs << {:weight_min => 0, :weight_max => 2000, :price => 8.35}
    @sc.configuration.shipping_costs << {:weight_min => 2001, :weight_max => 5000, :price => 10.20}
    @sc.configuration.shipping_costs << {:weight_min => 5001, :weight_max => 31000, :price => 15.20}
    @sc.tax_class = FactoryGirl.create(:tax_class)
    @sc.save
    ConfigurationItem.create(:key => 'default_shipping_calculator_id', :value => @sc.id)
  end
  
  before(:each) do
    @cart = Cart.new
    @cart.add_product(FactoryGirl.create(:product, :weight => 10.0))
    @cart.add_product(FactoryGirl.create(:product, :weight => 10.0), 2)
    expect(@cart.weight).to eq 30.0
  end
  
  it "finds its maximum weight correctly" do
    expect(@sc.maximum_weight).to eq 31000
  end
  
  it "finds the correct package count based on weight" do
    expect(@sc.package_count_for_weight(31000)).to eq 1
    expect(@sc.package_count_for_weight(31001)).to eq 2
    expect(@sc.package_count_for_weight(120000)).to eq 4
  end
  
  it "returns a shipping cost when given a document, based on the documents's weight" do
     #sc = ShippingCalculatorBasedOnWeight.new
     @sc.calculate_for(@cart)
     expect(@sc.cost).to eq BigDecimal.new("15.20") # 1 package under 31 kg
  end
  
  it "splits large shipments into multiple packages" do
    @cart.add_product(FactoryGirl.create(:product, :weight => 30.0))
    expect(@cart.weight).to eq 60.0
    @sc.calculate_for(@cart)
    expect(@sc.package_count).to eq 2
  end

  it "adds up the cost correctly, even for multiple packages" do
    @cart.add_product(FactoryGirl.create(:product, :weight => 30.0))
    expect(@cart.weight).to eq 60.0
    @sc.calculate_for(@cart)
    expect(@sc.package_count).to eq 2

    expect(@sc.cost).to eq BigDecimal.new("30.40") # 2 packages, total weight 60.0
    
    @cart.add_product(FactoryGirl.create(:product, :weight => 30.0), 2)
    expect(@cart.weight).to eq 120.0
    @sc.calculate_for(@cart)
    expect(@sc.package_count).to eq 4
    expect(@sc.cost).to eq BigDecimal.new("60.80")
  end
 

  it "uses the shipping fee for the lightest possible package if the weight of the item is exactly 0.0" do
    light_cart = Cart.new
    light_cart.add_product(FactoryGirl.create(:product, :weight => 0.0))
    expect(light_cart.weight).to eq 0.0
    @sc.calculate_for(light_cart)
    expect(@sc.cost).to eq BigDecimal.new("8.35")

  end
 
end
