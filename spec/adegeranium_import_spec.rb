# encoding: utf-8

require 'spec_helper'
require_relative '../lib/adegeranium_util'

describe AdegeraniumUtil do
  before(:each) do
    SupplyItem.count.should == 0
    Supplier.find_or_create_by(:name => "ADE!Geranium")
  end

  describe "importing supply items from CSV" do

    it "should import 3 items" do
      AdegeraniumTestHelper.import_from_file(Rails.root + "spec/data/adegeranium_complete.csv")
      SupplyItem.count.should == 3
      supplier = Supplier.where(:name => 'ADE!Geranium').first

      supply_item_should_be(supplier, "ADE50075", { :name => "ADE!geranium",
                                              :weight => 0.0,
                                              :purchase_price => BigDecimal.new("744.45"),
                                              :stock => 0} )
    end


    it "should construct a default name for supply items" do
      data = {} 
      data[:name01] = "ADE!Geranium, hier ein sehr langer Text der für einen Produktnamen viel zu lang ist"
      data[:supplier_product_code] = "1ABC XYZ"
      data[:product_link] = "http://www.example.com"
      au = AdegeraniumUtil.new
      au.construct_supply_item_name(data).should == "ADE!Geranium"
    end
  end
end
