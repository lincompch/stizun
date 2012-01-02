require 'spec_helper'


describe ShippingCalculator do
  
end

describe ShippingCalculatorBasedOnWeight do

  before(:each) do
    @cart = Cart.new
    @cart.add_product(Factory.create(:product, :weight => 10.0))
    @cart.add_product(Factory.create(:product, :weight => 10.0), 2)
    @cart.weight.should == 30.0
  end

  it "returns a shipping cost when given a document, based on the documents's weight" do
  
#     binding.pry
     sc = ShippingCalculatorBasedOnWeight.new
     sc.calculate_for(@cart)
     sc.cost.should == BigDecimal.new("15.20")    
  end

end