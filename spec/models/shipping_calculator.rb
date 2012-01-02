require 'spec_helper'


describe ShippingCalculators::ShippingCalculator do
  
end

describe ShippingCalculators::WeightBased do

  before(:each) do
    @cart = Cart.new
    @cart.add_product(Factory.create(:product, :weight => 10.0))
    @cart.add_product(Factory.create(:product, :weight => 10.0), 2)
    @cart.weight.should == 30.0
  end

  it "returns a shipping cost when given a document, based on the documents's weight" do
  
#     binding.pry
     sc = ShippingCalculators::WeightBased.new
     sc.calculate_for(@cart)
     sc.cost.should == BigDecimal.new("15.20")
#     sc.taxes.should == @cart.weight
    
  end

end