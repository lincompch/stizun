require 'spec_helper'


describe ShippingCalculator do
  
end

describe ShippingCalculatorBasedOnWeight do

  before(:all) do
    @sc = ShippingCalculatorBasedOnWeight.create(:name => 'For Testing')
    @sc.configuration.behavior = "ShippingCalculatorBasedOnWeight"
    @sc.configuration.shipping_costs = []
    @sc.configuration.shipping_costs << {:weight_min => 0, :weight_max => 2000, :price => 8.35}
    @sc.configuration.shipping_costs << {:weight_min => 2001, :weight_max => 5000, :price => 10.20}
    @sc.configuration.shipping_costs << {:weight_min => 5001, :weight_max => 31000, :price => 15.20}
    @sc.save
  end
  
  before(:each) do
    @cart = Cart.new
    @cart.add_product(Fabricate(:product, :weight => 10.0))
    @cart.add_product(Fabricate(:product, :weight => 10.0), 2)
    @cart.weight.should == 30.0
  end
  
  it "finds its maximum weight correctly" do
    @sc.maximum_weight.should == 31000
  end
  
  it "finds the correct package count based on weight" do
    @sc.package_count_for_weight(31000).should == 1
    @sc.package_count_for_weight(31001).should == 2
    @sc.package_count_for_weight(120000).should == 4
  end
  
  it "returns a shipping cost when given a document, based on the documents's weight" do
     #sc = ShippingCalculatorBasedOnWeight.new
     @sc.calculate_for(@cart)
     @sc.cost.should == BigDecimal.new("15.20") # 1 package under 31 kg
  end
  
  it "splits large shipments into multiple packages" do
    @cart.add_product(Fabricate(:product, :weight => 30.0))
    @cart.weight.should == 60.0
    @sc.calculate_for(@cart)
    @sc.package_count.should == 2
  end


  it "adds up the cost correctly, even for multiple packages" do
    @cart.add_product(Fabricate(:product, :weight => 30.0))
    @cart.weight.should == 60.0
    @sc.calculate_for(@cart)
    @sc.package_count.should == 2

    @sc.cost.should == BigDecimal.new("30.40") # 2 packages, total weight 60.0
    
    @cart.add_product(Fabricate(:product, :weight => 30.0), 2)
    @cart.weight.should == 120.0
    @sc.calculate_for(@cart)
    @sc.package_count.should == 4
    @sc.cost.should == BigDecimal.new("60.80")
  end
  
end
