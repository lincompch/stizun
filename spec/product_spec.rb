require 'spec_helper'

describe Product do
  
  describe "the system in general" do
    it "should have some supply items" do
      create_supplier("Alltron AG")
      create_supply_items.count.should > 0
    end
  end
  
  describe "a componentized product" do
    it "should have some specific supply items in the system" do
      array = [
        { 'name' => 'Some fast CPU', 'purchase_price' => 115.0,
          'weight' => 4.5, 'tax_percentage' => 8.0 },
        { 'name' => 'Cool RAM', 'purchase_price' => 220.0,
          'weight' => 0.3, 'tax_percentage' => 8.0 },
        { 'name' => 'An old Mainboard', 'purchase_price' => 80.0,
          'weight' => 1.2, 'tax_percentage' => 8.0 },
        { 'name' => 'Semi-broken case with PSU', 'purchase_price' => 20.0,
          'weight' => 10.2, 'tax_percentage' => 8.0 },
        { 'name' => 'Defective screen', 'purchase_price' => 200.0,
          'weight' => 2.8, 'tax_percentage' => 8.0 }
      ]
      
      DatabaseCleaner.start
      supply_items = create_supply_items(array)
      SupplyItem.all.count.should == 5
      DatabaseCleaner.clean
    end
  end
  
end