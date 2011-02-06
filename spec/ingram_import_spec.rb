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

      supply_item_should_be(supplier, "180538", { :manufacturer => 'Dymo',
                                                :weight => 0.23,
                                                :purchase_price => 18.70,
                                                :stock => 110} )
      
      supply_item_should_be(supplier, "180631", { :manufacturer => 'Dymo',
                                                :weight => 0.05,
                                                :purchase_price => 15.30,
                                                :stock => 41} )
      
      supply_item_should_be(supplier, "018Z055", { :manufacturer => 'Dymo',
                                                :weight => 0.06,
                                                :purchase_price => 16.70,
                                                :stock => 33} )
      
      supply_item_should_be(supplier, "711186", { :manufacturer => 'Netgear',
                                                :weight => 8.21,
                                                :purchase_price => 863.80,
                                                :stock => 0} )
            
      
      History.where(:text => "Supply item added during sync: 711186 ReadyNas NV+ 2TB Gigabit Desk",
                    :type_const => History::SUPPLY_ITEM_CHANGE).first.nil?.should == false
    end
    
    it "should change items when they have changed in the CSV file" do
      SupplyItem.count.should == 0
      IngramTestHelper.import_from_file(Rails.root + "spec/data/370_im_products_with_4_changes.csv")
      SupplyItem.count.should == 370
      supplier = Supplier.where(:name => 'Ingram Mico GmbH').first

      
      supply_item_should_be(supplier, "180538", { :manufacturer => 'Dymo',
                                                :weight => 0.23,
                                                :purchase_price => 19.70,
                                                :stock => 110} )
      
      supply_item_should_be(supplier, "180631", { :manufacturer => 'Dymo',
                                                :weight => 0.10,
                                                :purchase_price => 15.30,
                                                :stock => 41} )
      
      supply_item_should_be(supplier, "018Z055", { :manufacturer => 'Dymo',
                                                :weight => 0.06,
                                                :purchase_price => 16.70,
                                                :stock => 100} )
      
      supply_item_should_be(supplier, "711186", { :manufacturer => 'Netgear',
                                                :weight => 12.4,
                                                :purchase_price => 1233.40,
                                                :stock => 15} )
      
    end
    
    it "should mark items as deleted when they were removed from the CSV file" do
      SupplyItem.count.should == 0
      IngramTestHelper.import_from_file(Rails.root + "spec/data/370_im_products.csv")
      SupplyItem.count.should == 370
      IngramTestHelper.import_from_file(Rails.root + "spec/data/360_im_products.csv")
      SupplyItem.count.should == 370 # but 10 of them marked deleted
      supplier = Supplier.where(:name => 'Ingram Mico GmbH').first

      product_codes = ["0711642", "0712027", "0712259", "0712530", "0712577", "07701A5", "07701F4", "07702U8", "07702V2", "0770987"]
      ids = SupplyItem.where(:supplier_product_code => product_codes, :supplier_id => supplier).collect(&:id)
      supply_items_should_be_marked_deleted(ids, supplier)
      history_should_exist(:text => "Marked Supply Item with supplier code 0712027 as deleted", 
                           :type_const => History::SUPPLY_ITEM_CHANGE)
      history_should_exist(:text => "Marked Supply Item with supplier code 07701A5 as deleted", 
                           :type_const => History::SUPPLY_ITEM_CHANGE)
      history_should_exist(:text => "Marked Supply Item with supplier code 07702U8 as deleted", 
                           :type_const => History::SUPPLY_ITEM_CHANGE)
      
    end
    
    it "should disable products whose supply items were removed" do
      IngramTestHelper.import_from_file(Rails.root + "spec/data/370_im_products.csv")
      supply_item = SupplyItem.where(:supplier_product_code => "0712259").first
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