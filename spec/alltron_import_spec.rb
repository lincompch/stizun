# encoding: utf-8

require 'spec_helper'
require_relative '../lib/alltron_util'

describe AlltronUtil do
  before(:each) do
    SupplyItem.count.should == 0
    Supplier.find_or_create_by_name(:name => "Alltron AG")
  end

  describe "importing supply items from CSV" do

    it "should import 500 items" do
      AlltronTestHelper.import_from_file(Rails.root + "spec/data/500_products.csv")
      SupplyItem.count.should == 500
      supplier = Supplier.where(:name => 'Alltron AG').first


      supply_item_should_be(supplier, 1289, { :name => "Transferrolle z.Telefax Brother Fax 910-930 ca. 2x230 Kopien (PC302RF)",
                                              :category01 => "Büromaterial/-bedarf",
                                              :category02 => "Bürogeräte",
                                              :category03 => "Fax",
                                              :weight => 0.54,
                                              :purchase_price => BigDecimal.new("40.38"),
                                              :stock => 4} )

      supply_item_should_be(supplier, 2313, { :name => "Tinte Canon BJC 2000/4x00/5000 Nachfüllpatrone farbig (0955A002)",
                                              :weight => 0.06,
                                              :purchase_price => BigDecimal.new("24.49"),
                                              :stock => 3} )

      supply_item_should_be(supplier, 3188, { :name => "HP C7971A: LTO-1 Ultrium Cardridge, 200GB (C7971A)",
                                              :weight => 0.28,
                                              :purchase_price => BigDecimal.new("36.90"),
                                              :stock => 55} )

      supply_item_should_be(supplier, 5509, { :name => "Tinte HP DeskJet 5550C, 450 cbi Nr. 56, schwarz, 19ml, P 7000'er Serie (C6656AE)",
                                              :weight => 0.08,
                                              :purchase_price => BigDecimal.new("19.80"),
                                              :stock => 545} )

      supply_item_should_be(supplier, 6591, { :name => "Tinte Stylus Photo 950 schwarz, 17ml (C13T03314010)",
                                              :weight => 0.07,
                                              :purchase_price => BigDecimal.new("20.91"),
                                              :stock => 2} )
      AlltronTestHelper.import_from_file(Rails.root + "spec/data/500_products.csv")
    end

    it "should change items that have products when the items changed in the CSV file" do
      SupplyItem.count.should == 0
      AlltronTestHelper.import_from_file(Rails.root + "spec/data/500_products.csv")
      SupplyItem.count.should == 500

      # Create products so only those get updated
      codes = [1289, 2313, 3188, 5509, 6591]
      codes.each do |code|
          supply_item = SupplyItem.where(:supplier_product_code => code).first
          product = Product.new_from_supply_item(supply_item)
          product.save.should == true
      end

      AlltronTestHelper.update_from_file(Rails.root + "spec/data/500_products_with_5_changes.csv")
      SupplyItem.count.should == 500
      supplier = Supplier.where(:name => 'Alltron AG').first


      supply_item_should_be(supplier, 1289, { :weight => 0.54,
                                              :purchase_price => BigDecimal.new("40.00"),
                                              :stock => 4} )

      supply_item_should_be(supplier, 2313, { :weight => 0.06,
                                              :purchase_price => BigDecimal.new("24.49"),
                                              :stock => 100} )

      supply_item_should_be(supplier, 3188, { :weight => 0.50,
                                              :purchase_price => BigDecimal.new("36.90"),
                                              :stock => 55} )

      supply_item_should_be(supplier, 5509, { :weight => 0.50,
                                              :purchase_price => BigDecimal.new("25.00"),
                                              :stock => 545} )

      supply_item_should_be(supplier, 6591, { :weight => 2.00,
                                              :purchase_price => BigDecimal.new("40.00"),
                                              :stock => 18} )

    end


    # It's only very very slow to use import_from_file when we already know that all the
    # potentially changed items are already in the DB
    it "importing over an older data set should update supply items even when there are no products available for them" do
      SupplyItem.count.should == 0
      AlltronTestHelper.import_from_file(Rails.root + "spec/data/500_products.csv")
      SupplyItem.count.should == 500
      AlltronTestHelper.import_from_file(Rails.root + "spec/data/500_products_with_5_changes.csv")
      SupplyItem.count.should == 500
      supplier = Supplier.where(:name => 'Alltron AG').first


      supply_item_should_be(supplier, 1289, { :weight => 0.54,
                                              :purchase_price => BigDecimal.new("40.00"),
                                              :stock => 4} )

      supply_item_should_be(supplier, 2313, { :weight => 0.06,
                                              :purchase_price => BigDecimal.new("24.49"),
                                              :stock => 100} )

      supply_item_should_be(supplier, 3188, { :weight => 0.50,
                                              :purchase_price => BigDecimal.new("36.90"),
                                              :stock => 55} )

      supply_item_should_be(supplier, 5509, { :weight => 0.50,
                                              :purchase_price => BigDecimal.new("25.00"),
                                              :stock => 545} )

      supply_item_should_be(supplier, 6591, { :weight => 2.00,
                                              :purchase_price => BigDecimal.new("40.00"),
                                              :stock => 18} )

    end


    it "should mark items as deleted when they were removed from the CSV file" do
      AlltronTestHelper.import_from_file(Rails.root + "spec/data/500_products.csv")
      SupplyItem.count.should == 500
      supplier = Supplier.where(:name => 'Alltron AG').first
      product_codes = [1227, 1510, 1841, 1847, 2180, 2193, 2353, 2379, 3220, 4264, 5048, 5768, 5862, 5863, 8209]

      # Create products so only those get updated/marked deleted
      # product_codes.each do |code|
      #   supply_item = SupplyItem.where(:supplier_product_code => code).first
      #   product = Product.new_from_supply_item(supply_item)
      #   product.save.should == true
      # end

      AlltronTestHelper.update_from_file(Rails.root + "spec/data/485_products.csv")
      SupplyItem.count.should == 500
      # The others should *not* be deleted
      SupplyItem.available.where(:supplier_id => supplier).count.should == 485

      ids = SupplyItem.where(:supplier_product_code => product_codes, :supplier_id => supplier).collect(&:id)
      supply_items_should_be_marked_deleted(ids, supplier)

    end

    it "should disable products whose supply items were removed" do
      AlltronTestHelper.import_from_file(Rails.root + "spec/data/500_products.csv")
      supply_item = SupplyItem.where(:supplier_product_code => 1227).first
      product = Product.new_from_supply_item(supply_item)
      product.save.should == true
      product.available?.should == true
      AlltronTestHelper.update_from_file(Rails.root + "spec/data/485_products.csv")
      supply_item.reload
      supply_item.status_constant.should == SupplyItem::DELETED

      product.reload
      product.available?.should == false

    end

    it "should import some EAN codes for supply items" do
      AlltronTestHelper.import_from_file(Rails.root + "spec/data/4_alltron.csv")
      SupplyItem.count.should == 4
      valid_codes = ["","4015867568453","4902580320744"]
      SupplyItem.all.each do |si|
        valid_codes.include?(si.ean_code).should == true
      end
    end
  end

  describe 'quick import of stock levels' do
    it 'should update supply item stock levels when read from an XML file' do
      AlltronTestHelper.import_from_file(Rails.root + "spec/data/4_alltron.csv")
      AlltronTestHelper.quick_update_stock(Rails.root + "spec/data/4_alltron_stock_updates.xml")
      product_codes = SupplyItem.all.collect(&:supplier_product_code) #[1028, 1116, 1227, 1257]
      product_codes.each do |pc|
        si = SupplyItem.where(:supplier_product_code => pc).first
        si.stock.should == 999
      end
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
    data[:product_link] = "http://www.example.com"
    au = AlltronUtil.new
    au.construct_supply_item_name(data).should == "#{data[:name01]} #{data[:name02]} (#{data[:name03]})"
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
    data[:product_link] = "http://www.example.com"
    au = AlltronUtil.new
    au.construct_supply_item_description(data).should == "#{data[:description01]} #{data[:description02]}"
  end

end
