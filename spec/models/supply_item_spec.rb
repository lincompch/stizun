require 'spec_helper'

describe SupplyItem do

  describe "#generate_categories" do
    it "should generate categories string after save" do
      supplier = Fabricate(:supplier, :name => "Supplier 1")
      supply_item = Fabricate.build(:supply_item, :supplier => supplier)
      supply_item.category_string.should == nil
      supply_item.save!
      supply_item.category_string.should == "Supplier 1 :: category1 :: category2 :: category3"
    end
  end

  describe "disabling its product" do
    it "should not disable its product even if the stock goes below 0" do
      supply_item = Fabricate.build(:supply_item)
      product = Fabricate.build(:product)
      supply_item.product = product
      product.save
      supply_item.stock = 10
      supply_item.save

      supply_item.stock = -1
      supply_item.save
      product.is_available.should == true
    end

    it "should not disable its product if there is enough stock" do
      supply_item = Fabricate.build(:supply_item)
      product = Fabricate.build(:product)
      supply_item.product = product
      product.save
      supply_item.stock = 10
      supply_item.save
      product.is_available.should == true
    end
  end

  describe "switching to cheaper supply items from other suppliers" do

    it "should recognize if it is a cheaper solution for a product we stock" do
      expensive_supplier = Fabricate(:supplier, :name => 'Expensive Supplier')
      cheap_supplier = Fabricate(:supplier, :name => 'Cheap Supplier')

      expensive_supply_item = Fabricate(:supply_item, :purchase_price => 2000.00, 
                                        :supplier => expensive_supplier, :supplier_product_code => '1234', 
                                        :manufacturer_product_code => 'ABC123',
                                        :description => 'This is expensive',
                                        :weight => 1.5)

      cheap_supply_item = Fabricate(:supply_item, :purchase_price => 1000.00, 
                                    :supplier => cheap_supplier, :supplier_product_code => '8379', 
                                    :manufacturer_product_code => 'ABC123',
                                    :description => 'This is cheaper',
                                    :weight => 1.2)

      
      expensive_product = Product.new_from_supply_item(expensive_supply_item)
      expensive_product.save.should == true
      expensive_product.cheaper_supply_items.count.should == 1
      expensive_product.cheaper_supply_items.include?(cheap_supply_item).should == true
      expensive_product.cheaper_supply_items.include?(expensive_supply_item).should == false
      
      expensive_supply_item.product.should_not == nil
      expensive_supply_item.product.cheaper_supply_item_available?.should == true
      
    end

    it "should not offer any cheaper supply items if their prices match exactly" do
      expensive_supplier = Fabricate(:supplier, :name => 'Expensive Supplier')
      cheap_supplier = Fabricate(:supplier, :name => 'Cheap Supplier')

      expensive_supply_item = Fabricate(:supply_item, :purchase_price => 2000.00, 
                                        :supplier => expensive_supplier, :supplier_product_code => '1234', 
                                        :manufacturer_product_code => 'ABC123',
                                        :description => 'This is expensive',
                                        :weight => 1.5)

      cheap_supply_item = Fabricate(:supply_item, :purchase_price => 2000.00, 
                                    :supplier => cheap_supplier, :supplier_product_code => '8379', 
                                    :manufacturer_product_code => 'ABC123',
                                    :description => 'This is cheaper',
                                    :weight => 1.2)

      
      expensive_product = Product.new_from_supply_item(expensive_supply_item)
      expensive_product.save.should == true
      expensive_product.cheaper_supply_items.count.should == 0
      expensive_product.cheaper_supply_items.include?(cheap_supply_item).should == false
      expensive_product.cheaper_supply_items.include?(expensive_supply_item).should == false
      
      expensive_supply_item.product.should_not == nil
      expensive_supply_item.product.cheaper_supply_item_available?.should == false      
    end


  end

end
