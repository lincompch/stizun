# encoding: utf-8

require 'spec_helper'
require_relative '../lib/ingram_util'

describe IngramUtil do
  before(:each) do
    describe "at the start of the tests, the system" do
      it "should have no supply items" do
        SupplyItem.count.should == 0
      end

      it "should have a supplier called 'Ingram Micro GmbH'" do
        supplier = Supplier.find_or_create_by_name(:name => "Ingram Micro GmbH")
        supplier.name.should == "Ingram Micro GmbH"
      end
    end
  end

  describe "importing supply items from CSV" do
    it "should import 370 items" do
      IngramTestHelper.import_from_file(Rails.root + "spec/data/370_im_products.csv")
      SupplyItem.count.should == 370
      supplier = Supplier.where(:name => 'Ingram Micro GmbH').first

      supply_item_should_be(supplier, "0180631", { :manufacturer => 'Dymo',
                                                :weight => 0.05,
                                                :purchase_price => 15.30,
                                                :stock => 41} )

      supply_item_should_be(supplier, "0180538", { :manufacturer => 'Dymo',
                                                :weight => 0.23,
                                                :purchase_price => 18.70,
                                                :stock => 110} )

      supply_item_should_be(supplier, "018Z055", { :manufacturer => 'Dymo',
                                                :weight => 0.06,
                                                :purchase_price => 16.70,
                                                :stock => 33} )

      supply_item_should_be(supplier, "0711186", { :manufacturer => 'Netgear',
                                                :weight => 8.21,
                                                :purchase_price => 863.80,
                                                :stock => 0} )

    end

    it "should change items when they have changed in the CSV file" do
      SupplyItem.count.should == 0
      IngramTestHelper.import_from_file(Rails.root + "spec/data/370_im_products.csv")
      SupplyItem.count.should == 370

      codes = ["0180631","0180538","018Z055","0711186"]
      codes.each do |code|
          supply_item = SupplyItem.where(:supplier_product_code => code).first
          product = Product.new_from_supply_item(supply_item)
          product.save.should == true
      end
      IngramTestHelper.update_from_file(Rails.root + "spec/data/370_im_products_with_4_changes.csv")
      SupplyItem.count.should == 370

      supplier = Supplier.where(:name => 'Ingram Micro GmbH').first

      supply_item_should_be(supplier, "0180631", { :manufacturer => 'Dymo',
                                                :weight => 0.10,
                                                :purchase_price => 15.30,
                                                :stock => 41} )

      supply_item_should_be(supplier, "0180538", { :manufacturer => 'Dymo',
                                                :weight => 0.23,
                                                :purchase_price => 19.70,
                                                :stock => 110} )

      supply_item_should_be(supplier, "018Z055", { :manufacturer => 'Dymo',
                                                :weight => 0.06,
                                                :purchase_price => 16.70,
                                                :stock => 100} )

      supply_item_should_be(supplier, "0711186", { :manufacturer => 'Netgear',
                                                :weight => 12.4,
                                                :purchase_price => 1233.40,
                                                :stock => 15} )

    end

    it "should mark items as deleted when they were removed from the CSV file" do
      SupplyItem.count.should == 0
      IngramTestHelper.import_from_file(Rails.root + "spec/data/370_im_products.csv")
      SupplyItem.count.should == 370

      supplier = Supplier.where(:name => 'Ingram Micro GmbH').first
      product_codes = ["0711642", "0712027", "0712259", "0712530", "0712577", "07701A5", "07701F4", "07702U8", "07702V2", "0770987"]

      # Create products so only those get updated/marked deleted
      # product_codes.each do |code|
      #   supply_item = SupplyItem.where(:supplier_product_code => code).first
      #   product = Product.new_from_supply_item(supply_item)
      #   product.save.should == true
      # end

      IngramTestHelper.update_from_file(Rails.root + "spec/data/360_im_products.csv")
      SupplyItem.count.should == 370 # but 10 of them marked deleted
      # The others should *not* be deleted
      SupplyItem.available.where(:supplier_id => supplier).count.should == 360

      ids = SupplyItem.where(:supplier_product_code => product_codes, :supplier_id => supplier).collect(&:id)
      supply_items_should_be_marked_deleted(ids, supplier)

    end

    it "should disable products whose supply items were removed" do
      IngramTestHelper.import_from_file(Rails.root + "spec/data/370_im_products.csv")
      supply_item = SupplyItem.where(:supplier_product_code => "0712259").first
      product = Product.new_from_supply_item(supply_item)
      product.save.should == true
      product.available?.should == true
      IngramTestHelper.update_from_file(Rails.root + "spec/data/360_im_products.csv")
      supply_item.reload
      supply_item.status_constant.should == SupplyItem::DELETED

      product.reload
      product.available?.should == false

    end
  end
end
