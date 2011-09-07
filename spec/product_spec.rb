# encoding: utf-8

require 'spec_helper'

describe Product do
  
  describe "the system in general" do
    it "should have some supply items" do
      supplier = create_supplier("Alltron AG")
      supply_items = create_supply_items(@supplier)
      supply_items.count.should > 0
    end
    
    it "should have a tax class" do
      @tax_class = TaxClass.create(:name => 'Test Tax Class', :percentage => 8.0)
      TaxClass.where(:name => 'Test Tax Class', :percentage => 8.0).first.should_not == nil
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
      supplier = create_supplier("Alltron AG")
      supply_items = create_supply_items(supplier, array)
      SupplyItem.all.count.should == 5
    end

    it "should have a correct price, a total of constituent supply items" do
      pending
    end

    it "should have correct taxes" do
      pending
    end

  
  end
  
  describe "a product" do
 
    it "should have basic information" do
      supplier = create_supplier("Alltron AG")
      supply_items = create_supply_items(supplier)
      supply_items.count.should > 0
      
      tax_class = TaxClass.create(:name => 'Test Tax Class', :percentage => 8.0)
      
      p = Product.new
      p.tax_class = tax_class
      p.name = "Something"
      p.description = "Some stuff"
      p.weight = 1.0
      p.supplier = supplier
      p.save.should == true
    end
    
      
    
  end
  
  
end
