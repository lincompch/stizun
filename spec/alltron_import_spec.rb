require 'spec_helper'
require 'lib/alltron_util'

describe AlltronUtil do
  
  describe "at the start of the tests, the system" do
    it "should have no supply items" do
      SupplyItem.count.should == 0
    end
    
    it "should have some shipping rate" do
      tax_class = TaxClass.find_or_create_by_percentage(:name => "8.0", :percentage => 8.0)
      sr = ShippingRate.new
      sr.tax_class = tax_class
      sr.name = "Alltron AG"
      sr.shipping_costs << ShippingCost.new(:weight_min => 0, :weight_max => 1000,
                                            :price => 10, :tax_class => tax_class)
      sr.shipping_costs << ShippingCost.new(:weight_min => 1001, :weight_max => 2000,
                                            :price => 20, :tax_class => tax_class)      
      sr.shipping_costs << ShippingCost.new(:weight_min => 2001, :weight_max => 3000,
                                            :price => 30, :tax_class => tax_class)   
      sr.shipping_costs << ShippingCost.new(:weight_min => 3001, :weight_max => 4000,
                                            :price => 40, :tax_class => tax_class)      
      sr.shipping_costs << ShippingCost.new(:weight_min => 4001, :weight_max => 5000,
                                            :price => 50, :tax_class => tax_class)         
      
      if !sr.save
        puts sr.errors.full_messages.inspect
      end
      sr.save.should == true  
      
    end
    
    it "should have a supplier called 'Alltron AG'" do
      Supplier.find_or_create_by_name(:name => "Alltron AG", :shipping_rate => ShippingRate.where(:name => "Alltron AG").first)
    end
  end
  
  
  describe "importing supply items from CSV" do
    
    it "should import 500 items" do
        AlltronTestHelper.import_from_file(Rails.root + "spec/data/500_products.csv")
        SupplyItem.count.should == 500
        
        puts "first chosen SI: #{SupplyItem.where(:supplier_product_code => 1289, :purchase_price => 40.38,
                                                  :stock => 4).first.inspect}"
        
        SupplyItem.where(:supplier_product_code => 1289, :weight => 0.54, 
                         :purchase_price => 40.38, :stock => 4).first.nil?.should == false
        
        
        SupplyItem.where(:supplier_product_code => 2313, :weight => 0.06, 
                         :purchase_price => 24.49, :stock => 3).first.nil?.should == false
        SupplyItem.where(:supplier_product_code => 3188, :weight => 0.28, 
                         :purchase_price => 36.90, :stock => 55).first.nil?.should == false        
        SupplyItem.where(:supplier_product_code => 5509, :weight => 0.08, 
                         :purchase_price => 19.80, :stock => 545).first.nil?.should == false        
        SupplyItem.where(:supplier_product_code => 6591, :weight => 0.07, 
                         :purchase_price => 20.91, :stock => 2).first.nil?.should == false        

        History.where(:text => "Supply item added during sync: 2313 Tinte Canon BJC 2000/4x00/5000 Nachfüllpatrone farbig",
                      :type_const => History::SUPPLY_ITEM_CHANGE).first.nil?.should == false
    end
    
  end
  
#    
#   Scenario: Importing list with 5 changes
#     When I import the file "features/data/500_products_with_5_changes.csv"
#     Then there are 500 supply items in the database
#     And the following supply items should exist:
#     |product_code|weight|price|stock|
#     |        1289|  0.54|40.00|    4|
#     |        2313|  0.06|24.49|  100|
#     |        3188|  0.50|36.90|   55|    
#     |        5509|  0.50|25.00|  545|    
#     |        6591|  2.00|40.00|   18|        
#   
#   Scenario: Importing list with 15 missing products
#     When I import the file "features/data/500_products.csv"
#     And I import the file "features/data/485_products_utf8.csv"
#     Then there are 485 supply items in the database
#     And the following supply items should not exist:
#     |product_code|
#     |1227|
#     |1510|
#     |1841|
#     |1847|
#     |2180|
#     |2193|
#     |2353|
#     |2379|
#     |3220|
#     |4264|
#     |5048|
#     |5768|
#     |5862|
#     |5863|
#     |8209|
#     And the following history entries exist:
#     |text                                       |type_const                 |
#     |Deleted Supply Item with supplier code 1227|History::SUPPLY_ITEM_CHANGE|
#     |Deleted Supply Item with supplier code 1510|History::SUPPLY_ITEM_CHANGE|
#     |Deleted Supply Item with supplier code 2180|History::SUPPLY_ITEM_CHANGE|
#     |Deleted Supply Item with supplier code 3220|History::SUPPLY_ITEM_CHANGE|
#     |Deleted Supply Item with supplier code 5862|History::SUPPLY_ITEM_CHANGE|
#     |Deleted Supply Item with supplier code 8209|History::SUPPLY_ITEM_CHANGE|    
  
  
end