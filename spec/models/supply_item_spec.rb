require 'spec_helper'

describe SupplyItem do

  describe "#generate_categories" do
    it "should generate categories string after save" do
      supply_item = Factory.build(:supply_item)
      supply_item.category_string.should == nil
      supply_item.save!
      supply_item.category_string.should == "Supplier 1 :: category1 :: category2 :: category3"
    end
  end

end
