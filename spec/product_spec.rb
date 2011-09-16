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
      tax_class = TaxClass.create(:name => 'Test Tax Class', :percentage => 8.0)
      supplier = create_supplier("Alltron AG")
      supply_items = create_supply_items(supplier)
      supply_items.count.should > 0 
      suplier = Supplier.where(:name => 'Alltron AG').first
      tax_class = TaxClass.where(:name => 'Test Tax Class').first
      p = Product.new
      p.tax_class = tax_class
      p.name = "Something"
      p.description = "Some stuff"
      p.weight = 1.0
      p.supplier = supplier
      p.save.should == true
    end
    
    
    # When a product switches to a supply item from another supplier (that has the same
    # manufacturer product code, of course), all the related data in the product
    # should update as well on save.
    it "should have its supply item product code updated when its supply item changes" do
      tax_class = TaxClass.create(:name => 'Test Tax Class', :percentage => 8.0)
      supplier = create_supplier("Some Company 1")
      supplier.supply_items.create(:name => "Switchable Supply Item", 
                                  :purchase_price => 50.0, 
                                  :weight => 20.0, 
                                  :tax_class => tax_class,
                                  :manufacturer_product_code => 'ABC',
                                  :supplier_product_code => '123')
      
      supplier2 = create_supplier("Some Company 2")
      supplier2.supply_items.create(:name => "Switchable Supply Item From Company 2", 
                                   :purchase_price => 10.0, 
                                   :weight => 20.0, 
                                   :tax_class => tax_class,
                                   :manufacturer_product_code => 'ABC',
                                   :supplier_product_code => '12345')
      
      si = supplier.supply_items.first
      p = Product.new_from_supply_item(si)
      p.name.should == "Switchable Supply Item"
      p.weight.should == 20.0
      p.manufacturer_product_code.should == "ABC"
      p.supplier_product_code.should == "123"
      p.supplier.should == supplier
      p.tax_class.should == si.tax_class
      p.save.should == true
      
      p.supply_item = supplier2.supply_items.first
      p.save.should == true
      p.supplier.should == supplier2
      p.supplier_product_code.should == "12345"
      p.supply_item.name.should == "Switchable Supply Item From Company 2"

    end
    
  end
  
  
end
