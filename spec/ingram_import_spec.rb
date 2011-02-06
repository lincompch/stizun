require 'spec_helper'
require 'lib/ingram_util'

describe IngramUtil do
  before(:each) do
    describe "at the start of the tests, the system" do
      it "should have no supply items" do
        SupplyItem.count.should == 0
      end
      
      it "should have some shipping rate" do
        tax_class = TaxClass.find_or_create_by_percentage(:name => "8.0", :percentage => 8.0)
        sr = ShippingRate.new
        sr.tax_class = tax_class
        sr.name = "Ingram Micro GmbH"
        sr.shipping_costs << ShippingCost.new(:weight_min => 0, :weight_max => 999999,
                                              :price => 14, :tax_class => tax_class)
        if !sr.save
          puts sr.errors.full_messages.inspect
        end
        sr.save.should == true  
        
      end
      
      it "should have a supplier called 'Ingram Micro GmbH'" do
        Supplier.find_or_create_by_name(:name => "Ingram Mico GmbH", 
                                        :shipping_rate => ShippingRate.where(:name => "Ingram Micro GmbH").first)
      end
      
    end
  end
  
  describe "importing supply items from CSV" do
    
    it "should import 370 items" do
      IngramTestHelper.import_from_file(Rails.root + "spec/data/370_im_products.csv")
      SupplyItem.count.should == 370
      supplier = Supplier.where(:name => 'Ingram Mico GmbH').first

                        # supplier_product_code, weight, purchase_price, stock
      supply_item_should_be(supplier, 1289, 0.54, 40.38, 4)
      supply_item_should_be(supplier, 2313, 0.06, 24.49, 3)
      supply_item_should_be(supplier, 3188, 0.28, 36.90, 55)
      supply_item_should_be(supplier, 5509, 0.08, 19.80, 545)
      supply_item_should_be(supplier, 6591, 0.07, 20.91, 2)

      History.where(:text => "Supply item added during sync: 2313 Tinte Canon BJC 2000/4x00/5000 Nachfüllpatrone farbig",
                    :type_const => History::SUPPLY_ITEM_CHANGE).first.nil?.should == false
    end
    
    it "should change items when they have changed in the CSV file" do
      SupplyItem.count.should == 0
      IngramTestHelper.import_from_file(Rails.root + "spec/data/370_im_products_with_4_changes.csv")
      SupplyItem.count.should == 370
      supplier = Supplier.where(:name => 'Ingram Mico GmbH').first

      supply_item_should_be(supplier, 1289, 0.54, 40.00, 4)
      supply_item_should_be(supplier, 2313, 0.06, 24.49, 100)
      supply_item_should_be(supplier, 3188, 0.50, 36.90, 55)
      supply_item_should_be(supplier, 5509, 0.50, 25.00, 545)
      supply_item_should_be(supplier, 6591, 2.00, 40.00, 18)
   
    end
    
    it "should mark items as deleted when they were removed from the CSV file" do
      SupplyItem.count.should == 0
      IngramTestHelper.import_from_file(Rails.root + "spec/data/370_im_products.csv")
      SupplyItem.count.should == 370
      IngramTestHelper.import_from_file(Rails.root + "spec/data/360_im_products.csv")
      SupplyItem.count.should == 370 # but 10 of them marked deleted
      supplier = Supplier.where(:name => 'Ingram Mico GmbH').first

      product_codes = [1227, 1510, 1841, 1847, 2180, 2193, 2353, 2379, 3220, 4264, 5048, 5768, 5862, 5863, 8209]
      ids = SupplyItem.where(:supplier_product_code => product_codes, :supplier_id => supplier).collect(&:id)
      supply_items_should_be_marked_deleted(ids, supplier)
      history_should_exist(:text => "Marked Supply Item with supplier code 1227 as deleted", 
                           :type_const => History::SUPPLY_ITEM_CHANGE)
      history_should_exist(:text => "Marked Supply Item with supplier code 3220 as deleted", 
                           :type_const => History::SUPPLY_ITEM_CHANGE)
      history_should_exist(:text => "Marked Supply Item with supplier code 8209 as deleted", 
                           :type_const => History::SUPPLY_ITEM_CHANGE)
      
    end
    
    it "should disable products whose supply items were removed" do
      IngramTestHelper.import_from_file(Rails.root + "spec/data/500_products.csv")
      supply_item = SupplyItem.where(:supplier_product_code => 1227).first
      product = Product.new_from_supply_item(supply_item)
      product.save.should == true
      product.available?.should == true      
      IngramTestHelper.import_from_file(Rails.root + "spec/data/360_im_products.csv")
      supply_item.reload
      supply_item.status_constant.should == SupplyItem::DELETED
      
      product.reload
      product.available?.should == false      

    end
    
    
  end

end