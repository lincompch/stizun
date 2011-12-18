require 'spec_helper'

describe SupplyItem do

  describe "#generate_categories" do
    it "should generate categories string after save" do
      supplier = Factory(:supplier, :name => "Supplier 1")
      supply_item = Factory.build(:supply_item, :supplier => supplier)
      supply_item.category_string.should == nil
      supply_item.save!
      supply_item.category_string.should == "Supplier 1 :: category1 :: category2 :: category3"
    end
  end

  describe "disabling its product" do
    it "should disable its product if the stock goes below 0" do
      supply_item = Factory.build(:supply_item)
      product = Factory.build(:product)
      supply_item.product = product
      product.save
      supply_item.stock = 10
      supply_item.save

      supply_item.stock = -1
      supply_item.save
      product.is_available.should == false
    end

    it "should not disable its product if there is enough stock" do
      supply_item = Factory.build(:supply_item)
      product = Factory.build(:product)
      supply_item.product = product
      product.save
      supply_item.stock = 10
      supply_item.save
      product.is_available.should == true
    end
  end

end
