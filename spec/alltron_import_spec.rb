# encoding: utf-8

require 'spec_helper'
require_relative '../lib/alltron_util'

describe AlltronUtil do
  before(:each) do
    expect(SupplyItem.count).to eq(0)
    Supplier.find_or_create_by(:name => "Alltron AG")
  end

  describe "importing supply items from CSV" do

    it "should import 500 items" do
      AlltronTestHelper.import_from_file(Rails.root + "spec/data/500_products.csv")
      expect(SupplyItem.count).to eq(500)
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
      expect(SupplyItem.count).to eq(0)
      AlltronTestHelper.import_from_file(Rails.root + "spec/data/500_products.csv")
      expect(SupplyItem.count).to eq(500)

      # Create products so only those get updated
      codes = [1289, 2313, 3188, 5509, 6591]
      codes.each do |code|
          supply_item = SupplyItem.where(:supplier_product_code => code).first
          product = Product.new_from_supply_item(supply_item)
          expect(product.save).to be true
      end

      AlltronTestHelper.update_from_file(Rails.root + "spec/data/500_products_with_5_changes.csv")
      expect(SupplyItem.count).to eq(500)
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
      expect(SupplyItem.count).to eq(0)
      AlltronTestHelper.import_from_file(Rails.root + "spec/data/500_products.csv")
      expect(SupplyItem.count).to eq(500)
      AlltronTestHelper.import_from_file(Rails.root + "spec/data/500_products_with_5_changes.csv")
      expect(SupplyItem.count).to eq(500)
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
      expect(SupplyItem.count).to eq(500)
      supplier = Supplier.where(:name => 'Alltron AG').first
      product_codes = [1227, 1510, 1841, 1847, 2180, 2193, 2353, 2379, 3220, 4264, 5048, 5768, 5862, 5863, 8209]

      AlltronTestHelper.update_from_file(Rails.root + "spec/data/485_products.csv")
      expect(SupplyItem.count).to eq(500)
      # The others should *not* be deleted
      expect(SupplyItem.available.where(:supplier_id => supplier).count).to eq(485)

      ids = SupplyItem.where(:supplier_product_code => product_codes, :supplier_id => supplier).collect(&:id)
      supply_items_should_be_marked_deleted(ids, supplier)

    end

    it "should disable products whose supply items were removed" do
      AlltronTestHelper.import_from_file(Rails.root + "spec/data/500_products.csv")
      supply_item = SupplyItem.where(:supplier_product_code => 1227).first
      product = Product.new_from_supply_item(supply_item)
      expect(product.save).to be true
      expect(product.available?).to be true
      AlltronTestHelper.update_from_file(Rails.root + "spec/data/485_products.csv")
      supply_item.reload
      expect(supply_item.status_constant).to eq(SupplyItem::DELETED)

      product.reload
      expect(product.available?).to be(false)

    end

    it "should import some EAN codes for supply items" do
      AlltronTestHelper.import_from_file(Rails.root + "spec/data/4_alltron.csv")
      expect(SupplyItem.count).to eq(4)
      valid_codes = ["","4015867568453","4902580320744"]
      SupplyItem.all.each do |si|
        expect(valid_codes.include?(si.ean_code)).to be(true)
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
        expect(si.stock).to eq(999)
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
    expect(au.construct_supply_item_name(data)).to eq("#{data[:name01]} #{data[:name02]} (#{data[:name03]})")
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
    expect(au.construct_supply_item_description(data)).to eq("#{data[:description01]} #{data[:description02]}")
  end

  it "should correctly construct all data even for pesky problematic items" do
    au = AlltronUtil.new
    au.import_supply_items(Rails.root + "spec/data/alltron_problematic_router.csv")
    si = SupplyItem.where(:supplier_product_code => '233063').first
    expect(si.description).to eq("Huawei B593: LTE/UMTS/HSDPA Modemrouter, 150Mbps/42.2Mbps download, WLAN, 4xLAN,USB, 2xRJ-11 Telefon Das schnellste 3G/4G Modemrouter auf der Welt. Unterstützt bis 2 analoge Festnetztelefone für Telefonieren über das 3G/4G LTE Datennetz.")
  end

  it "should not overwrite the product description if it is locked" do
      AlltronTestHelper.import_from_file(Rails.root + "spec/data/4_alltron.csv")
      expect(SupplyItem.count).to eq(4)

      SupplyItem.all.each do |si|
        p = Product.new_from_supply_item(si)
        p.save
      end

      expect(Product.count).to eq(4)

      p1 = Product.where(:supplier_product_code => '1028').first
      p2 = Product.where(:supplier_product_code => '1116').first

      p1.is_description_protected = true
      expect(p1.save).to be(true)
      p2.is_description_protected = false
      expect(p2.save).to be(true)

      AlltronTestHelper.update_from_file(Rails.root + "spec/data/4_alltron_changed_descriptions.csv")

      expect((p1.reload.description =~ /^CHANGED/)).to be(nil)
      expect((p2.reload.description =~ /^CHANGED/)).to eq(0)
  end

end
