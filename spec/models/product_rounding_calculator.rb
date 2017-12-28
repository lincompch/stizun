require 'spec_helper'

describe ProductRoundingCalculator do


  context "Swiss rounding with real products" do

    it "should work inside real Product objects" do

      ConfigurationItem.create(:key => 'rounding_component_rules', :value => 'swiss')

      tc = FactoryGirl.create(:tax_class, :percentage => 8.0)
      mr = FactoryGirl.build(:margin_range)
      mr.start_price = nil
      mr.end_price = nil
      mr.margin_percentage = 5.0
      expect(mr.save).to eq true      
      p = FactoryGirl.build(:product)
      p.tax_class = tc
      p.purchase_price = BigDecimal.new("123.45")
      expect(p.save).to eq true
      
      expect(p.rounding_component).to eq BigDecimal.new("0.679047619048E-2")

      expect((p.taxed_price.rounded % 5).to_s).to eq "0.0" # Should end up rounded to something that ends in 0.05
    end    

    it "should work also with products that have a percentage rebate" do

      ConfigurationItem.create(:key => 'rounding_component_rules', :value => 'swiss')

      tc = FactoryGirl.create(:tax_class, :percentage => 8.0)
      mr = FactoryGirl.build(:margin_range)
      mr.start_price = nil
      mr.end_price = nil
      mr.margin_percentage = 5.0
      expect(mr.save).to eq true      
      p = FactoryGirl.build(:product)
      p.tax_class = tc
      p.purchase_price = BigDecimal.new("123.45")
      p.rebate_until = DateTime.now + 1.year
      p.percentage_rebate = BigDecimal.new("8.4")
      expect(p.save).to eq true

      expect((p.taxed_price.rounded % 5).to_s).to eq "0.0" # Should end up rounded to something that ends in 0.05
    end    

    it "should work also with products that have an absolute rebate" do

      ConfigurationItem.create(:key => 'rounding_component_rules', :value => 'swiss')

      tc = FactoryGirl.create(:tax_class, :percentage => 8.0)
      mr = FactoryGirl.build(:margin_range)
      mr.start_price = nil
      mr.end_price = nil
      mr.margin_percentage = 5.0
      expect(mr.save).to eq true      
      p = FactoryGirl.build(:product)
      p.tax_class = tc
      p.purchase_price = BigDecimal.new("123.45")
      p.rebate_until = DateTime.now + 1.year
      p.absolute_rebate = BigDecimal.new("20.0")
      expect(p.save).to eq true

      expect((p.taxed_price.rounded % 5).to_s).to eq "0.0" # Should end up rounded to something that ends in 0.05
    end    

  end


  it "Swiss rounding: should return the change necessary to price calculation so final prices round to 0.05" do

    ConfigurationItem.create(:key => 'rounding_component_rules', :value => 'swiss')    

    rounding_component = ProductRoundingCalculator.calculate_rounding_component(:purchase_price => BigDecimal.new("123.45"), 
                                                                               :margin_percentage => BigDecimal.new("5.0"), 
                                                                               :tax_percentage => BigDecimal.new("8.0"),
                                                                               :rebate => BigDecimal.new("0.0"))
    expect(rounding_component).to eq BigDecimal.new("0.679047619048E-2")
    new_purchase_price = BigDecimal.new("123.45") + rounding_component
    expect(new_purchase_price).to eq BigDecimal.new("0.12345679047619048E3")

  end

  it "should not round anything if no rounding component configuration is specified" do
    ci = ConfigurationItem.where(:key => 'rounding_component_rules').first
    ci.destroy unless ci.nil?

    rounding_component = ProductRoundingCalculator.calculate_rounding_component(:purchase_price => BigDecimal.new("123.45"), 
                                                                               :margin_percentage => BigDecimal.new("5.0"), 
                                                                               :tax_percentage => BigDecimal.new("8.0"),
                                                                               :rebate => BigDecimal.new("0.0"))
    expect(rounding_component).to eq BigDecimal.new("0.0")

  end


end
