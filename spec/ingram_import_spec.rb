# encoding: utf-8

require 'spec_helper'
require_relative '../lib/ingram_util'

describe IngramUtil do
  before(:each) do
    expect(SupplyItem.count).to eq 0
    supplier = Supplier.find_or_create_by(:name => "Ingram Micro GmbH")
  end

  describe "importing supply items from CSV" do
    it "should import 39 items" do
      IngramTestHelper.import_from_file(Rails.root + "spec/data/PL_6xxxxx.csv")
      expect(SupplyItem.count).to eq 39
      supplier = Supplier.where(:name => 'Ingram Micro GmbH').first

      supply_item_should_be(supplier, "0585EJ5", { :manufacturer => 'LENOVO',
                                                :weight => 0.34,
                                                :purchase_price => BigDecimal.new("44.00"),
                                                :stock => 20} )

      supply_item_should_be(supplier, "2M3WT00", { :manufacturer => 'HP INC.',
                                                :weight => 7.64,
                                                :purchase_price => BigDecimal.new("954.89"),
                                                :stock => 41} )
    end

    it "should auto-create products if there is a CategoryDispatcher to match supply items to local product categories" do
      supplier = Supplier.where(:name => 'Ingram Micro GmbH').first
      target_category = FactoryGirl.create(:category, {:name => 'Test'})
      CategoryDispatcher.create(
        :level_01 => 'Computersysteme',
        :level_02 => 'Notebooks',
        :level_03 => '',
        :categories => [target_category],
        :supplier_id => supplier.id
      )
      IngramTestHelper.import_from_file(Rails.root + "spec/data/PL_6xxxxx.csv")
      # dispatcher = CategoryDispatcher.find_by(level_01: 'Computersysteme', level_02: 'Notebooks')
      # dispatcher.categories = [target_category]
      # dispatcher.save
      # binding.pry
      expect(SupplyItem.count).to eq 39
      expect(target_category.products.count).to eq 5
    end

    it "should import EAN codes for supply items" do
      IngramTestHelper.import_from_file(Rails.root + "spec/data/PL_6xxxxx.csv")
      expect(SupplyItem.count).to eq 39
      expect(SupplyItem.first.ean_code).to_not be("")
      expect(SupplyItem.first.ean_code).to_not be_nil
      # SupplyItem.all.each do |si|
      #   expect(si.ean_code).to_not be("")
      #   expect(si.ean_code).to_not be_nil
      # end
    end

  end


  it "should construct a default name for supply items" do
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
    iu = IngramUtil.new
    expect(iu.construct_supply_item_name(data)).to eq "#{data[:name01]} #{data[:name02]} (#{data[:name03]})"
  end

  it "should construct a default description for supply items" do
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
    iu = IngramUtil.new
    expect(iu.construct_supply_item_description(data)).to eq "#{data[:description01]} #{data[:description02]}"
  end

end
