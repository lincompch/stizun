require 'spec_helper'

describe MarginRange do

   it "should calculate a margin percentage based on the price passed into it" do
      # This is the default margin range that gets used if nothing else fits
      mr0 = Factory.build(:margin_range)
      mr0.start_price = nil
      mr0.end_price = nil
      mr0.margin_percentage = 5.0
      mr0.save
      
      mr1 = Factory.build(:margin_range)
      mr1.start_price = 0
      mr1.end_price = 50
      mr1.margin_percentage = 8.0
      mr1.save
      
      mr2 = Factory.build(:margin_range)
      mr2.start_price = 50.01
      mr2.end_price = 150
      mr2.margin_percentage = 10.0
      mr2.save
      
      MarginRange.percentage_for_price(20).should == 8.0
      MarginRange.percentage_for_price(120).should == 10.0
      MarginRange.percentage_for_price(390).should == 5.0

    end
    
    
   it "should be used during product margin calculation" do
      # This is the default margin range that gets used if nothing else fits
      mr0 = Factory.build(:margin_range)
      mr0.start_price = nil
      mr0.end_price = nil
      mr0.margin_percentage = 5.0
      mr0.save
      
      mr1 = Factory.build(:margin_range)
      mr1.start_price = 0
      mr1.end_price = 50
      mr1.margin_percentage = 8.0
      mr1.save
      
      mr2 = Factory.build(:margin_range)
      mr2.start_price = 50.01
      mr2.end_price = 150
      mr2.margin_percentage = 10.0
      mr2.save
      
      p = Factory.build(:product)
      p.purchase_price = 45
      p.margin_percentage.to_s.should == "8.0" # Comes as a BigDecimal, that's why .to_s
      
      p2 = Factory.build(:product)
      p2.purchase_price = 80
      p2.margin_percentage.to_s.should == "10.0"
      
      # Checking for the default margin percentage as defined in the database
      p3 = Factory.build(:product)
      p3.purchase_price = 290
      p3.margin_percentage.to_s.should == "5.0"
    end
    
    
end