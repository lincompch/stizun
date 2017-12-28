# encoding: utf-8

require 'spec_helper'
require_relative '../lib/ingram_util'

describe IngramUtil do
  before(:each) do
    expect(SupplyItem.count).to eq 0
    supplier = Supplier.find_or_create_by(:name => "Ingram Micro GmbH")
  end

  describe "importing supply items from CSV" do
    it "should import 370 items" do
      IngramTestHelper.import_from_file(Rails.root + "spec/data/370_im_products.csv")
      expect(SupplyItem.count).to eq 370
      supplier = Supplier.where(:name => 'Ingram Micro GmbH').first

      supply_item_should_be(supplier, "0180631", { :manufacturer => 'Dymo',
                                                :weight => 0.05,
                                                :purchase_price => BigDecimal.new("15.30"),
                                                :stock => 41} )

      supply_item_should_be(supplier, "0180538", { :manufacturer => 'Dymo',
                                                :weight => 0.23,
                                                :purchase_price => BigDecimal.new("18.70"),
                                                :stock => 110} )

      supply_item_should_be(supplier, "018Z055", { :manufacturer => 'Dymo',
                                                :weight => 0.06,
                                                :purchase_price => BigDecimal.new("16.70"),
                                                :stock => 33} )

      supply_item_should_be(supplier, "0711186", { :manufacturer => 'Netgear',
                                                :weight => 8.21,
                                                :purchase_price => BigDecimal.new("863.80"),
                                                :stock => 0} )

    end

    it "should change items when they have changed in the CSV file" do
      expect(SupplyItem.count).to eq 0
      IngramTestHelper.import_from_file(Rails.root + "spec/data/370_im_products.csv")
      expect(SupplyItem.count).to eq 370

      codes = ["0180631","0180538","018Z055","0711186"]
      codes.each do |code|
          supply_item = SupplyItem.where(:supplier_product_code => code).first
          product = Product.new_from_supply_item(supply_item)
          expect(product.save).to be true
      end
      IngramTestHelper.update_from_file(Rails.root + "spec/data/370_im_products_with_4_changes.csv")
      expect(SupplyItem.count).to eq 370

      supplier = Supplier.where(:name => 'Ingram Micro GmbH').first

      supply_item_should_be(supplier, "0180631", { :manufacturer => 'Dymo',
                                                :weight => 0.10,
                                                :purchase_price => BigDecimal.new("15.30"),
                                                :stock => 41} )

      supply_item_should_be(supplier, "0180538", { :manufacturer => 'Dymo',
                                                :weight => 0.23,
                                                :purchase_price => BigDecimal.new("19.70"),
                                                :stock => 110} )

      supply_item_should_be(supplier, "018Z055", { :manufacturer => 'Dymo',
                                                :weight => 0.06,
                                                :purchase_price => BigDecimal.new("16.70"),
                                                :stock => 100} )

      supply_item_should_be(supplier, "0711186", { :manufacturer => 'Netgear',
                                                :weight => 12.4,
                                                :purchase_price => BigDecimal.new("1233.40"),
                                                :stock => 15} )

    end

    it "should mark items as deleted when they were removed from the CSV file" do
      expect(SupplyItem.count).to eq 0
      IngramTestHelper.import_from_file(Rails.root + "spec/data/370_im_products.csv")
      expect(SupplyItem.count).to eq 370

      supplier = Supplier.where(:name => 'Ingram Micro GmbH').first
      product_codes = ["0711642", "0712027", "0712259", "0712530", "0712577", "07701A5", "07701F4", "07702U8", "07702V2", "0770987"]

      IngramTestHelper.update_from_file(Rails.root + "spec/data/360_im_products.csv")
      expect(SupplyItem.count).to eq 370 # but 10 of them marked deleted
      # The others should *not* be deleted
      expect(SupplyItem.available.where(:supplier_id => supplier).count).to eq 360

      ids = SupplyItem.where(:supplier_product_code => product_codes, :supplier_id => supplier).collect(&:id)
      supply_items_should_be_marked_deleted(ids, supplier)

    end

    it "should disable products whose supply items were removed" do
      IngramTestHelper.import_from_file(Rails.root + "spec/data/370_im_products.csv")
      supply_item = SupplyItem.where(:supplier_product_code => "0712259").first
      product = Product.new_from_supply_item(supply_item)
      expect(product.save).to be true
      expect(product.available?).to be true
      IngramTestHelper.update_from_file(Rails.root + "spec/data/360_im_products.csv")
      supply_item.reload
      expect(supply_item.status_constant).to eq SupplyItem::DELETED

      product.reload
      expect(product.available?).to be false

    end

    # *Supply Item, das einst "not available" war, erscheint wieder im CSV-File*
    it "should re-enable products if their supply items become available again" do
      IngramTestHelper.import_from_file(Rails.root + "spec/data/supply_item_reappears_01.csv")
      sup1 = SupplyItem.where(:supplier_product_code => "0180009").first
      sup2 = SupplyItem.where(:supplier_product_code => "0180014").first

      prod1 = Product.new_from_supply_item(sup1)
      prod1.save
      prod2 = Product.new_from_supply_item(sup2)
      prod2.save

      IngramTestHelper.update_from_file(Rails.root + "spec/data/supply_item_reappears_02.csv")

      expect(sup1.status_constant).to eq SupplyItem::AVAILABLE
      sup2.reload
      expect(sup2.status_constant).to eq SupplyItem::DELETED
      
      expect(prod1.reload.is_available).to be true
      expect(prod2.reload.is_available).to be false

      IngramTestHelper.update_from_file(Rails.root + "spec/data/supply_item_reappears_03.csv")

      expect(sup1.status_constant).to eq SupplyItem::AVAILABLE
      sup2.reload
      expect(sup2.status_constant).to eq SupplyItem::AVAILABLE
      
      expect(prod1.reload.is_available).to eq true
      expect(prod2.reload.is_available).to eq true
    end

    # *Supply Item erhält danach wieder Stückzahl über 0*
    it "should re-enable products if their stock count goes over 0 again" do
      IngramTestHelper.import_from_file(Rails.root + "spec/data/supply_item_stock_comes_back_above_zero_01.csv")
      sup = SupplyItem.where(:supplier_product_code => "0180009").first
      prod = Product.new_from_supply_item(sup)
      prod.save

      IngramTestHelper.update_from_file(Rails.root + "spec/data/supply_item_stock_comes_back_above_zero_02.csv")
      sup.reload
      expect(sup.stock).to eq 0

      prod.reload
      expect(prod.stock).to eq 0
      expect(prod.is_available).to be true # It's available, but with 0 in stock

      IngramTestHelper.update_from_file(Rails.root + "spec/data/supply_item_stock_comes_back_above_zero_03.csv")
      sup.reload
      expect(sup.stock).to eq 12


      prod.reload
      expect(prod.stock).to eq 12
      expect(prod.is_available).to be true
    end

    it "should check if a changed price makes a supply item cheaper than an existing one, then it should change the product to that" do

      # The item 123XXX45 costs 5.00 at both places at the moment
      IngramTestHelper.import_from_file(Rails.root + "spec/data/supply_item_price_change_makes_it_the_cheaper_option_01_ingram.csv")
      AlltronTestHelper.import_from_file(Rails.root + "spec/data/supply_item_price_change_makes_it_the_cheaper_option_01_alltron.csv")
      
      ingram = Supplier.where(:name => 'Ingram Micro GmbH').first
      alltron = Supplier.where(:name => 'Alltron AG').first
      sup = ingram.supply_items.where(:manufacturer_product_code => "123XXX45").first
      prod = Product.new_from_supply_item(sup)
      prod.save
      expect(prod.purchase_price.to_f).to eq 5.0

      AlltronTestHelper.update_from_file(Rails.root + "spec/data/supply_item_price_change_makes_it_the_cheaper_option_02_alltron.csv")
      sup_alltron = alltron.supply_items.where(:manufacturer_product_code => "123XXX45").first
      expect(sup_alltron.purchase_price.to_f).to eq 2.0


      # The product should have switched itself to this new option, the cheaper supply item from Alltron
      prod.reload
      expect(prod.supplier).to eq alltron
      expect(prod.supply_item).to eq sup_alltron
      expect(prod.purchase_price.to_f).to eq 2.0


      # Product.update_price_and_stock
      # prod.reload
      # prod.stock.should == 0
      # prod.is_available.should == true # It's available, but with 0 in stock

    end

    it "should auto-create products if there is a CategoryDispatcher to match supply items to local product categories" do
 
      CategoryDispatcher.destroy_all
      target_category = FactoryGirl.create(:category, {:name => 'Test'})
      FactoryGirl.create(:category_dispatcher, {:level_01 => 'Verbrauchsmaterial',
                                                :level_02 => 'Etiketten',
                                                :level_03 => 'Labeldrucker',
                                                :categories => [target_category]})
      IngramTestHelper.import_from_file(Rails.root + "spec/data/4_im.csv")
      # Only 3 out of 4 of the products in the file have a matching combination of categories to be automatically assigned
      expect(target_category.products.count).to eq 3
      expect(SupplyItem.count).to eq 4
    end

    it "should import EAN codes for supply items" do
      IngramTestHelper.import_from_file(Rails.root + "spec/data/4_im.csv")
      expect(SupplyItem.count).to eq 4
      SupplyItem.all.each do |si|
        expect(si.ean_code).to_not be("")
        expect(si.ean_code).to_not be_nil
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
