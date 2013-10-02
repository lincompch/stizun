# encoding: utf-8

require 'spec_helper'
require_relative '../lib/alltron2013_util'

describe Alltron2013Util do
  before(:each) do
    SupplyItem.count.should == 0
    sup = Supplier.find_or_create_by_name(:name => "Alltron AG")
    sup.utility_class_name = "Alltron2013Util"
    sup.save
  end

  describe "importing supply items from CSV" do

    it "should import 10 items" do
      Alltron2013TestHelper.import_from_file(Rails.root + "spec/data/alltron2013/10_products.csv")
      SupplyItem.count.should == 10
      supplier = Supplier.where(:name => 'Alltron AG').first


      supply_item_should_be(supplier, 1289, { :name => "Transferrolle z.Telefax Brother Fax 910-930 ca. 2x230 Kopien (PC302RF)",
                                              :category01 => "Telekommunikation",
                                              :category02 => "Telefonie",
                                              :category03 => "Telefonie Zubehör",
                                              :weight => 0.54,
                                              :purchase_price => BigDecimal.new("44.44"),
                                              :stock => 2} )

      supply_item_should_be(supplier, 1510, { :name => "Monitor Verlängerungs-Netzkabel 220 V Kaltgerätestecker für Netzteilanschluss (PC 60009-1,8)",
                                              :weight => 0.18,
                                              :purchase_price => BigDecimal.new("11.94"),
                                              :stock => 253} )
      #Alltron2013TestHelper.import_from_file(Rails.root + "spec/data/alltron2013/10_products.csv")
    end

  #  it "should change items that have products when the items changed in the CSV file" do
  #    SupplyItem.count.should == 0
  #    Alltron2013TestHelper.import_from_file(Rails.root + "spec/data/alltron2013/10_products.csv")
  #    SupplyItem.count.should == 10

  #    # Create products so only those get updated
  #    codes = [1289, 2313, 3188, 5509, 6591]
  #    codes.each do |code|
  #        supply_item = SupplyItem.where(:supplier_product_code => code).first
  #        product = Product.new_from_supply_item(supply_item)
  #        product.save.should == true
  #    end

  #    Alltron2013TestHelper.update_from_file(Rails.root + "spec/data/alltron2013/10_products_with_5_changes.csv")
  #    SupplyItem.count.should == 10
  #    supplier = Supplier.where(:name => 'Alltron AG').first


  #    supply_item_should_be(supplier, 1289, { :weight => 0.54,
  #                                            :purchase_price => BigDecimal.new("40.00"),
  #                                            :stock => 4} )

  #    supply_item_should_be(supplier, 2313, { :weight => 0.06,
  #                                            :purchase_price => BigDecimal.new("24.49"),
  #                                            :stock => 100} )

  #    supply_item_should_be(supplier, 3188, { :weight => 0.50,
  #                                            :purchase_price => BigDecimal.new("36.90"),
  #                                            :stock => 55} )

  #    supply_item_should_be(supplier, 5509, { :weight => 0.50,
  #                                            :purchase_price => BigDecimal.new("25.00"),
  #                                            :stock => 545} )

  #    supply_item_should_be(supplier, 6591, { :weight => 2.00,
  #                                            :purchase_price => BigDecimal.new("40.00"),
  #                                            :stock => 18} )

  #  end


  #  # It's only very very slow to use import_from_file when we already know that all the
  #  # potentially changed items are already in the DB
  #  it "importing over an older data set should update supply items even when there are no products available for them" do
  #    SupplyItem.count.should == 0
  #    Alltron2013TestHelper.import_from_file(Rails.root + "spec/data/alltron2013/10_products.csv")
  #    SupplyItem.count.should == 10
  #    Alltron2013TestHelper.import_from_file(Rails.root + "spec/data/alltron2013/10_products_with_5_changes.csv")
  #    SupplyItem.count.should == 10
  #    supplier = Supplier.where(:name => 'Alltron AG').first


  #    supply_item_should_be(supplier, 1289, { :weight => 0.54,
  #                                            :purchase_price => BigDecimal.new("40.00"),
  #                                            :stock => 4} )

  #    supply_item_should_be(supplier, 2313, { :weight => 0.06,
  #                                            :purchase_price => BigDecimal.new("24.49"),
  #                                            :stock => 100} )

  #    supply_item_should_be(supplier, 3188, { :weight => 0.50,
  #                                            :purchase_price => BigDecimal.new("36.90"),
  #                                            :stock => 55} )

  #    supply_item_should_be(supplier, 5509, { :weight => 0.50,
  #                                            :purchase_price => BigDecimal.new("25.00"),
  #                                            :stock => 545} )

  #    supply_item_should_be(supplier, 6591, { :weight => 2.00,
  #                                            :purchase_price => BigDecimal.new("40.00"),
  #                                            :stock => 18} )

  #  end


  #  it "should mark items as deleted when they were removed from the CSV file" do
  #    Alltron2013TestHelper.import_from_file(Rails.root + "spec/data/alltron2013/10_products.csv")
  #    SupplyItem.count.should == 10
  #    supplier = Supplier.where(:name => 'Alltron AG').first
  #    product_codes = [1227, 1510, 1841, 1847, 2180]

  #    Alltron2013TestHelper.update_from_file(Rails.root + "spec/data/alltron2013/5_products.csv")
  #    SupplyItem.count.should == 10
  #    # The others should *not* be deleted
  #    SupplyItem.available.where(:supplier_id => supplier).count.should == 10

  #    ids = SupplyItem.where(:supplier_product_code => product_codes, :supplier_id => supplier).collect(&:id)
  #    supply_items_should_be_marked_deleted(ids, supplier)

  #  end

  #  it "should disable products whose supply items were removed" do
  #    Alltron2013TestHelper.import_from_file(Rails.root + "spec/data/alltron2013/10_products.csv")
  #    supply_item = SupplyItem.where(:supplier_product_code => 1227).first
  #    product = Product.new_from_supply_item(supply_item)
  #    product.save.should == true
  #    product.available?.should == true
  #    Alltron2013TestHelper.update_from_file(Rails.root + "spec/data/alltron2013/5_products.csv")
  #    supply_item.reload
  #    supply_item.status_constant.should == SupplyItem::DELETED

  #    product.reload
  #    product.available?.should == false

  #  end

  #  it "should import some EAN codes for supply items" do
  #    Alltron2013TestHelper.import_from_file(Rails.root + "spec/data/alltron2013/3_alltron_with_ean.csv")
  #    SupplyItem.count.should == 4
  #    valid_codes = ["","4015867568453","4902580320744"]
  #    SupplyItem.all.each do |si|
  #      valid_codes.include?(si.ean_code).should == true
  #    end
  #  end
  #end


  #it "should construct a default name for supply items" do
  #  data = {} 
  #  data[:name01] = "HP"
  #  data[:name02] = "Super-Special Paper"
  #  data[:name03] = "Of Extreme Quality"
  #  data[:ean_code] = "0123ABC123"
  #  data[:manufacturer] = "Hewlett-Packard"
  #  data[:supplier_product_code] = "1ABC XYZ"
  #  data[:manufacturer_product_code] = "HP Ugly Description Lala"
  #  data[:description01] = "Some Description"
  #  data[:description02] = "Some Second Description"
  #  data[:product_link] = "http://www.example.com"
  #  au = Alltron2013Util.new
  #  au.construct_supply_item_name(data).should == "#{data[:name01]} #{data[:name02]} (#{data[:name03]})"
  #end

  #it "should construct a default description for supply items" do
  #  data = {} 
  #  data[:name01] = "HP"
  #  data[:name02] = "Super-Special Paper"
  #  data[:name03] = "Of Extreme Quality"
  #  data[:ean_code] = "0123ABC123"
  #  data[:manufacturer] = "Hewlett-Packard"
  #  data[:supplier_product_code] = "1ABC XYZ"
  #  data[:manufacturer_product_code] = "HP Ugly Description Lala"
  #  data[:description01] = "Some Description"
  #  data[:description02] = "Some Second Description"
  #  data[:product_link] = "http://www.example.com"
  #  au = Alltron2013Util.new
  #  au.construct_supply_item_description(data).should == "#{data[:description01]} #{data[:description02]}"
  #end

  #it "should correctly construct all data even for pesky problematic items" do
  #  au = Alltron2013Util.new
  #  au.import_supply_items(Rails.root + "spec/data/alltron2013/alltron_problematic_router.csv")
  #  si = SupplyItem.where(:supplier_product_code => '233063').first
  #  si.description.should == "Huawei B593: LTE/UMTS/HSDPA Modemrouter, 150Mbps/42.2Mbps download, WLAN, 4xLAN,USB, 2xRJ-11 Telefon Das schnellste 3G/4G Modemrouter auf der Welt. Unterstützt bis 2 analoge Festnetztelefone für Telefonieren über das 3G/4G LTE Datennetz."
  #end

  #it "should not overwrite the product description if it is locked" do
  #    Alltron2013TestHelper.import_from_file(Rails.root + "spec/data/alltron2013/3_alltron_with_ean.csv")
  #    SupplyItem.count.should == 4

  #    SupplyItem.all.each do |si|
  #      p = Product.new_from_supply_item(si)
  #      p.save
  #    end

  #    Product.count.should == 4

  #    p1 = Product.where(:supplier_product_code => '1028').first
  #    p2 = Product.where(:supplier_product_code => '1116').first

  #    p1.is_description_protected = true
  #    p1.save.should == true
  #    p2.is_description_protected = false
  #    p2.save.should == true

  #    Alltron2013TestHelper.update_from_file(Rails.root + "spec/data/alltron2013/4_alltron_changed_descriptions.csv")

  #    (p1.reload.description =~ /^CHANGED/).should == nil
  #    (p2.reload.description =~ /^CHANGED/).should == 0
  #end
    
  end
end
