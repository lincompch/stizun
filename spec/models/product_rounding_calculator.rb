require 'spec_helper'

describe ProductRoundingCalculator do


  context "Swiss rounding with real products" do

    it "should work inside real Product objects" do

      ConfigurationItem.create(:key => 'rounding_component_rules', :value => 'swiss')

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

      (p.taxed_price.rounded % 5).to_s.should == "0.0" # Should end up rounded to something that ends in 0.05
    end    

    it "should work also with products that have a percentage rebate" do

      ConfigurationItem.create(:key => 'rounding_component_rules', :value => 'swiss')

      tc = Fabricate(:tax_class, :percentage => 8.0)
      mr = Fabricate.build(:margin_range)
      mr.start_price = nil
      mr.end_price = nil
      mr.margin_percentage = 5.0
      mr.save.should == true      
      p = Fabricate.build(:product)
      p.tax_class = tc
      p.purchase_price = BigDecimal.new("123.45")
      p.rebate_until = DateTime.now + 1.year
      p.percentage_rebate = BigDecimal.new("8.4")
      p.save.should == true

      (p.taxed_price.rounded % 5).to_s.should == "0.0" # Should end up rounded to something that ends in 0.05
    end    

    it "should work also with products that have an absolute rebate" do

      ConfigurationItem.create(:key => 'rounding_component_rules', :value => 'swiss')

      tc = Fabricate(:tax_class, :percentage => 8.0)
      mr = Fabricate.build(:margin_range)
      mr.start_price = nil
      mr.end_price = nil
      mr.margin_percentage = 5.0
      mr.save.should == true      
      p = Fabricate.build(:product)
      p.tax_class = tc
      p.purchase_price = BigDecimal.new("123.45")
      p.rebate_until = DateTime.now + 1.year
      p.absolute_rebate = BigDecimal.new("20.0")
      p.save.should == true

      (p.taxed_price.rounded % 5).to_s.should == "0.0" # Should end up rounded to something that ends in 0.05
    end    

  end


  it "Swiss rounding: should return the change necessary to price calculation so final prices round to 0.05" do

    ConfigurationItem.create(:key => 'rounding_component_rules', :value => 'swiss')    

    rounding_component = ProductRoundingCalculator.calculate_rounding_component(:purchase_price => BigDecimal.new("123.45"), 
                                                                               :margin_percentage => BigDecimal.new("5.0"), 
                                                                               :tax_percentage => BigDecimal.new("8.0"),
                                                                               :rebate => BigDecimal.new("0.0"))
    rounding_component.should == BigDecimal.new("0.679047619048E-2")
    new_purchase_price = BigDecimal.new("123.45") + rounding_component
    new_purchase_price.should == BigDecimal.new("0.12345679047619048E3")

  end

  it "should not round anything if no rounding component configuration is specified" do
    ci = ConfigurationItem.where(:key => 'rounding_component_rules').first
    ci.destroy unless ci.nil?

    rounding_component = ProductRoundingCalculator.calculate_rounding_component(:purchase_price => BigDecimal.new("123.45"), 
                                                                               :margin_percentage => BigDecimal.new("5.0"), 
                                                                               :tax_percentage => BigDecimal.new("8.0"),
                                                                               :rebate => BigDecimal.new("0.0"))
    rounding_component.should == BigDecimal.new("0.0")

  end


end
