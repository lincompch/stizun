# encoding: utf-8

require 'spec_helper'
require_relative '../lib/pocketmedia_util'

describe PocketmediaUtil do
  before(:each) do
    SupplyItem.count.should == 0
    Supplier.find_or_create_by_name(:name => "Pocketmedia")
  end

  describe "importing supply items from CSV" do

    it "should import 83 items" do
      PocketmediaTestHelper.import_from_file(Rails.root + "spec/data/85_pocketmedia.csv")
      SupplyItem.count.should == 83
      supplier = Supplier.where(:name => 'Pocketmedia').first


      supply_item_should_be(supplier, "10 50 0086", { :name => "WLAN, Internet TV / Radio, 4.3\" TFT, Remote Control, Clock",
                                                      :category01 => "Internetradio",
                                                      :category02 => "Internet TV",
                                                      :weight => 0.7,
                                                      :purchase_price => BigDecimal.new("110.0")}
                           )
    end
  end
end
