require 'spec_helper'

describe ProductRoundingCalculator do


  context "with real products" do

    it "should work inside real Product objects" do
      tc = Fabricate(:tax_class, :percentage => 8.0)
      mr = Fabricate.build(:margin_range)
      mr.start_price = nil
      mr.end_price = nil
      mr.margin_percentage = 5.0
      mr.save.should == true      
      p = Fabricate.build(:product)
      p.tax_class = tc
      p.purchase_price = BigDecimal.new("123.45")
      p.save.should == true

      p.rounding_component.should == BigDecimal.new("0.679047619048E-2")
    end    

  end


  it "should return the change necessary to price calculation so final prices round to 0.05 in Swiss rounding mode" do

    rounding_component = ProductRoundingCalculator.calculate_rounding_component(:purchase_price => BigDecimal.new("123.45"), 
                                                                               :margin_percentage => BigDecimal.new("5.0"), 
                                                                               :tax_percentage => BigDecimal.new("8.0"),
                                                                               :rebate => BigDecimal.new("0.0"))
    rounding_component.should == BigDecimal.new("0.679047619048E-2")
    new_purchase_price = BigDecimal.new("123.45") + rounding_component
    new_purchase_price.should == BigDecimal.new("0.12345679047619048E3")

  end


end
