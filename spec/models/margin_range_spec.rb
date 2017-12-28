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
      
      expect(MarginRange.percentage_for_price(20)).to eq 8.0
      expect(MarginRange.percentage_for_price(120)).to eq 10.0
      expect(MarginRange.percentage_for_price(390)).to eq 5.0

    end

   it "should use a linear transform to map the number of one range to a range of percentages, if given" do

     # When the purchase price falls between 20 and 80, map that to a percentage that falls linearly between 10 and 30
     mr0 = FactoryGirl.build(:margin_range)
     mr0.start_price = 20.0
     mr0.end_price = 80.0
     mr0.margin_percentage = nil
     mr0.band_minimum = 50.0
     mr0.band_maximum = 10.0  
     expect(mr0.save).to eq true
     expect(MarginRange.percentage_for_price(20.0)).to eq 50.0
     expect(MarginRange.percentage_for_price(24.0)).to eq 41.111111111111114
     expect(MarginRange.percentage_for_price(79.7)).to eq 10.050188205771644
     expect(MarginRange.percentage_for_price(80.0)).to eq 10.0
     expect(MarginRange.percentage_for_price(41.0)).to eq 22.682926829268293
     expect(MarginRange.percentage_for_price(23.0)).to eq 43.04347826086957

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
      expect(p.margin_percentage.to_s).to eq "8.0" # Comes as a BigDecimal, that's why .to_s
      
      p2 = FactoryGirl.build(:product)
      p2.purchase_price = BigDecimal.new("80")
      expect(p2.margin_percentage.to_s).to eq "10.0"
      
      # Checking for the default margin percentage as defined in the database
      p3 = FactoryGirl.build(:product)
      p3.purchase_price = BigDecimal.new("290")
      expect(p3.margin_percentage.to_s).to eq "5.0"
    end
    
    it "should be able to re-save all products affected by a product- or supplier-specific margin range creation or deletion, so that their cached prices are updated" do
      supplier = FactoryGirl.create(:supplier)


      product1 = FactoryGirl.build(:product, :purchase_price => BigDecimal.new("100.0"))
      product1.supplier = supplier
      expect(product1.save).to eq true

      product2 = FactoryGirl.build(:product, :purchase_price => BigDecimal.new("200.0"))
      product2.supplier = supplier
      expect(product2.save).to eq true

      MarginRange.destroy_all # In case FactoryGirl.create is messing things up
      expect(MarginRange.count).to eq 0

      # right now it uses the hard-coded margin range, since there was no applicable margin range defined yet.

      # default system-wide margin range gets defined
      mr0 = FactoryGirl.build(:margin_range)
      mr0.start_price = nil
      mr0.end_price = nil
      mr0.margin_percentage = 10.0
      expect(mr0.save).to eq true
      expect(MarginRange.count).to eq 1
    
      #mr0.recalculate_affected_products
      MarginRange.recalculate_recently_changed_products

      product1.reload
      expect(product1.margin.to_f).to eq 10.0
      expect(product1.gross_price.to_f).to eq 110.0
      expect(product1.taxed_price.to_f).to eq 132.0 # Plus 20% taxes

      product2.reload
      expect(product2.margin.to_f).to eq 20.0
      expect(product2.gross_price.to_f).to eq 220.0
      expect(product2.taxed_price.to_f).to eq 264.0 # Plus 20% taxes


      mr1 = FactoryGirl.build(:margin_range)
      mr1.start_price = nil
      mr1.end_price = nil
      mr1.supplier = supplier
      mr1.margin_percentage = 20.0
      expect(mr1.save).to eq true
      expect(MarginRange.count).to eq 2

#      mr1.recalculate_affected_products
      MarginRange.recalculate_recently_changed_products


      supplier.reload
      product1.reload
      expect(product1.margin.to_f).to eq 20.0
      expect(product1.gross_price.to_f).to eq 120.0
      expect(product1.taxed_price.to_f).to eq 144.0

      product2.reload
      expect(product2.margin.to_f).to eq 40.0
      expect(product2.gross_price.to_f).to eq 240.0
      expect(product2.taxed_price.to_f).to eq 288.0

      mr2 = FactoryGirl.build(:margin_range)
      mr2.start_price = nil
      mr2.end_price = nil
      mr2.product = product1
      mr2.margin_percentage = 30.0
      expect(mr2.save).to eq true
      expect(MarginRange.count).to eq 3

      mr3 = FactoryGirl.build(:margin_range)
      mr3.start_price = nil
      mr3.end_price = nil
      mr3.product = product2
      mr3.margin_percentage = 30.0
      expect(mr3.save).to eq true
      expect(MarginRange.count).to eq 4

 #     mr2.recalculate_affected_products
 #     mr3.recalculate_affected_products

      MarginRange.recalculate_recently_changed_products

      product1.reload
      product2.reload

      expect(product1.margin.to_f).to eq 30.0
      expect(product1.gross_price.to_f).to eq 130.0
      expect(product1.taxed_price.to_f).to eq 156.0
      expect(product2.margin.to_f).to eq 60.0
      expect(product2.gross_price.to_f).to eq 260.0
      expect(product2.taxed_price.to_f).to eq 312.0

    end
end
