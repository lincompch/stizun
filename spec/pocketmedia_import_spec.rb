# encoding: utf-8

require 'spec_helper'
require_relative '../lib/pocketmedia_util'

describe PocketmediaUtil do
  before(:each) do
    expect(SupplyItem.count).to eq 0
    Supplier.find_or_create_by(:name => "Pocketmedia")
  end

  describe "importing supply items from CSV" do

    it "should import 83 items" do
      PocketmediaTestHelper.import_from_file(Rails.root + "spec/data/85_pocketmedia.csv")
      expect(SupplyItem.count).to eq 83
      supplier = Supplier.where(:name => 'Pocketmedia').first


      supply_item_should_be(supplier, "10 50 0086", { :name => "Albrecht DR800-TV (4032661274809)",
                                                      :category01 => "Internetradio",
                                                      :category02 => "Internet TV",
                                                      :weight => 0.7,
                                                      :purchase_price => BigDecimal.new("110.0")}
                           )
    end
  end


  it "should construct a nice name for supply items" do
    data = {} 
    data[:name01] = "HP"
    data[:name02] = "Super-Special Paper"
    data[:name03] = "Of Extreme Quality"
    data[:ean_code] = "0123ABC123"
    data[:manufacturer] = "Hewlett-Packard"
    data[:supplier_product_code] = "1ABC XYZ"
    data[:manufacturer_product_code] = "HP Ugly Description Lala"
    data[:description01] = "Some Description"
    data[:description02] = "Some Second Description"
    pmu = PocketmediaUtil.new
    expect(pmu.construct_supply_item_name(data)).to eq "#{data[:manufacturer]} #{data[:manufacturer_product_code]} (#{data[:ean_code]})"
  end

  it "should construct a nice description for supply items" do
    data = {} 
    data[:name01] = "HP"
    data[:name02] = "Super-Special Paper"
    data[:name03] = "Of Extreme Quality"
    data[:ean_code] = "0123ABC123"
    data[:manufacturer] = "Hewlett-Packard"
    data[:supplier_product_code] = "1ABC XYZ"
    data[:manufacturer_product_code] = "HP Ugly Description Lala"
    data[:description01] = "Some Description"
    data[:description02] = "Some Second Description"
    pmu = PocketmediaUtil.new
    expect(pmu.construct_supply_item_description(data)).to eq "#{data[:name01]}"
  end


end
