require 'spec_helper'

describe MarginRange do

   it "should calculate a margin percentage based on the price passed into it" do
      # This is the default margin range that gets used if nothing else fits
      mr0 = FactoryGirl.build(:margin_range)
      mr0.start_price = nil
      mr0.end_price = nil
      mr0.margin_percentage = 5.0
      mr0.save
      
      mr1 = FactoryGirl.build(:margin_range)
      mr1.start_price = 0
      mr1.end_price = 50
      mr1.margin_percentage = 8.0
      mr1.save
      
      mr2 = FactoryGirl.build(:margin_range)
      mr2.start_price = 50.01
      mr2.end_price = 150
      mr2.margin_percentage = 10.0
      mr2.save
      
      MarginRange.percentage_for_price(20).should == 8.0
      MarginRange.percentage_for_price(120).should == 10.0
      MarginRange.percentage_for_price(390).should == 5.0

    end

   it "should use a linear transform to map the number of one range to a range of percentages, if given" do

     # When the purchase price falls between 20 and 80, map that to a percentage that falls linearly between 10 and 30
     mr0 = FactoryGirl.build(:margin_range)
     mr0.start_price = 20.0
     mr0.end_price = 80.0
     mr0.margin_percentage = nil
     mr0.band_minimum = 50.0
     mr0.band_maximum = 10.0  
     mr0.save.should == true
     MarginRange.percentage_for_price(20.0).should == 50.0
     MarginRange.percentage_for_price(24.0).should == 41.111111111111114
     MarginRange.percentage_for_price(79.7).should == 10.016687526074259 
     MarginRange.percentage_for_price(80.0).should == 10.0
     MarginRange.percentage_for_price(41.0).should == 22.682926829268293
     MarginRange.percentage_for_price(23.0).should == 43.04347826086957

   end
    
    
   it "should be used during product margin calculation" do
      # This is the default margin range that gets used if nothing else fits
      mr0 = FactoryGirl.build(:margin_range)
      mr0.start_price = nil
      mr0.end_price = nil
      mr0.margin_percentage = 5.0
      mr0.save
      
      mr1 = FactoryGirl.build(:margin_range)
      mr1.start_price = 0
      mr1.end_price = 50
      mr1.margin_percentage = 8.0
      mr1.save
      
      mr2 = FactoryGirl.build(:margin_range)
      mr2.start_price = 50.01
      mr2.end_price = 150
      mr2.margin_percentage = 10.0
      mr2.save
      
      p = FactoryGirl.build(:product)
      p.purchase_price = BigDecimal.new("45")
      p.margin_percentage.to_s.should == "8.0" # Comes as a BigDecimal, that's why .to_s
      
      p2 = FactoryGirl.build(:product)
      p2.purchase_price = BigDecimal.new("80")
      p2.margin_percentage.to_s.should == "10.0"
      
      # Checking for the default margin percentage as defined in the database
      p3 = FactoryGirl.build(:product)
      p3.purchase_price = BigDecimal.new("290")
      p3.margin_percentage.to_s.should == "5.0"
    end
    
    it "should be able to re-save all products affected by a product- or supplier-specific margin range creation or deletion, so that their cached prices are updated" do
      supplier = FactoryGirl.create(:supplier)


      product1 = FactoryGirl.build(:product, :purchase_price => BigDecimal.new("100.0"))
      product1.supplier = supplier
      product1.save.should == true

      product2 = FactoryGirl.build(:product, :purchase_price => BigDecimal.new("200.0"))
      product2.supplier = supplier
      product2.save.should == true

      MarginRange.destroy_all # In case FactoryGirl.create is messing things up
      MarginRange.count.should == 0

      # right now it uses the hard-coded margin range, since there was no applicable margin range defined yet.

      # default system-wide margin range gets defined
      mr0 = FactoryGirl.build(:margin_range)
      mr0.start_price = nil
      mr0.end_price = nil
      mr0.margin_percentage = 10.0
      mr0.save.should == true
      MarginRange.count.should == 1
    
      #mr0.recalculate_affected_products
      MarginRange.recalculate_recently_changed_products

      product1.reload
      product1.margin.to_f.should == 10.0
      product1.gross_price.to_f.should == 110.0
      product1.taxed_price.to_f.should == 132.0 # Plus 20% taxes

      product2.reload
      product2.margin.to_f.should == 20.0
      product2.gross_price.to_f.should == 220.0
      product2.taxed_price.to_f.should == 264.0 # Plus 20% taxes


      mr1 = FactoryGirl.build(:margin_range)
      mr1.start_price = nil
      mr1.end_price = nil
      mr1.supplier = supplier
      mr1.margin_percentage = 20.0
      mr1.save.should == true
      MarginRange.count.should == 2

#      mr1.recalculate_affected_products
      MarginRange.recalculate_recently_changed_products


      supplier.reload
      product1.reload
      product1.margin.to_f.should == 20.0
      product1.gross_price.to_f.should == 120.0
      product1.taxed_price.to_f.should == 144.0

      product2.reload
      product2.margin.to_f.should == 40.0
      product2.gross_price.to_f.should == 240.0
      product2.taxed_price.to_f.should == 288.0

      mr2 = FactoryGirl.build(:margin_range)
      mr2.start_price = nil
      mr2.end_price = nil
      mr2.product = product1
      mr2.margin_percentage = 30.0
      mr2.save.should == true
      MarginRange.count.should == 3

      mr3 = FactoryGirl.build(:margin_range)
      mr3.start_price = nil
      mr3.end_price = nil
      mr3.product = product2
      mr3.margin_percentage = 30.0
      mr3.save.should == true
      MarginRange.count.should == 4

 #     mr2.recalculate_affected_products
 #     mr3.recalculate_affected_products

      MarginRange.recalculate_recently_changed_products

      product1.reload
      product2.reload

      product1.margin.to_f.should == 30.0
      product1.gross_price.to_f.should == 130.0
      product1.taxed_price.to_f.should == 156.0
      product2.margin.to_f.should == 60.0
      product2.gross_price.to_f.should == 260.0
      product2.taxed_price.to_f.should == 312.0

    end
end
