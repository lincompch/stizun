# encoding: utf-8

require 'spec_helper'

describe Product do

  describe "the system in general" do
    it "should have some supply items" do
      supplier = create_supplier("Alltron AG")
      supply_items = create_supply_items(@supplier)
      supply_items.count.should > 0
    end
    
    it "should have a tax class" do
      @tax_class = TaxClass.create(:name => 'Test Tax Class', :percentage => "8.0")
      TaxClass.where(:name => 'Test Tax Class', :percentage => "8.0").first.should_not == nil
    end
  end
  
  describe "a product" do
    before(:each) do
      @tax_class = TaxClass.create(:name => 'Test Tax Class', :percentage => "8.0")
      @supplier = create_supplier("Alltron AG")
      supply_items = create_supply_items(@supplier)
      supply_items.count.should > 0 
      @suplier = Supplier.where(:name => 'Alltron AG').first
      p = Product.new
      p.tax_class = @tax_class
      p.name = "Something"
      p.description = "Some stuff"
      p.weight = 1.0
      p.supplier = @supplier
      p.save.should == true
    end

    
    it "should be able to retrieve a product picture and PDF if the respective URLs are valid" do
      download_dir = Rails.root + "tmp/downloads"
      system("mkdir -p #{download_dir}") unless Dir.exist?("tmp/downloads")
      p = FactoryGirl.build(:product)
      p.supplier = @supplier
      si = FactoryGirl.build(:supply_item)
      si.image_url = "http://l.yimg.com/g/images/en-us/flickr-yahoo-logo.png.v3"
      si.pdf_url = "http://www.scala-lang.org/sites/default/files/linuxsoft_archives/docu/files/ScalaByExample.pdf"
      si.save.should == true
      
      p.supply_item = si
      p.save.should == true      
      p.try_to_get_product_files
      
      image_path = "#{download_dir}/#{p.supply_item.id}_#{File.basename(si.image_url)}"
      pdf_path = "#{download_dir}/#{p.supply_item.id}_#{File.basename(si.pdf_url)}"
      puts image_path, pdf_path
      File.exist?(image_path).should == true
      File.exist?(pdf_path).should == true
    end
    
    it "should use the most specific margin range available to it for price calculation" do
      supplier = FactoryGirl.create(:supplier)

      product = FactoryGirl.build(:product)
      product.purchase_price = "100.0"
      product.supplier = supplier
      product.save.should == true

      MarginRange.destroy_all # Sometimes FactoryGirl.build goes a little overboard creating associated records

      # default system-wide margin range
      mr0 = FactoryGirl.build(:margin_range)
      mr0.start_price = nil
      mr0.end_price = nil
      mr0.margin_percentage = 10.0
      mr0.save.should == true

      product.margin_percentage.should == 10.0
      
      mr1 = FactoryGirl.build(:margin_range)
      mr1.start_price = nil
      mr1.end_price = nil
      mr1.supplier = supplier
      mr1.margin_percentage = 20.0
      mr1.save.should == true
      supplier.reload
      product.margin_percentage.should == 20.0

      mr2 = FactoryGirl.build(:margin_range)
      mr2.start_price = nil
      mr2.end_price = nil
      mr2.product = product
      mr2.margin_percentage = 30.0
      mr2.save.should == true
      product.reload

      product.margin_percentage.should == 30.0

    end

    # When a product switches to a supply item from another supplier (that has the same
    # manufacturer product code, of course), all the related data in the product
    # should update as well on save.
    it "should have its supply item product code updated when its supply item changes to another supplier's identical supply item" do
      supplier = create_supplier("Some Company 1")
      supplier.supply_items.create(:name => "Switchable Supply Item",
                                   :description => "It's switchable",
                                  :purchase_price => "50.0", 
                                  :weight => 20.0, 
                                  :manufacturer_product_code => 'ABC',
                                  :supplier_product_code => '123')
      
      supplier2 = create_supplier("Some Company 2")
      supplier2.supply_items.create(:name => "Switchable Supply Item From Company 2", 
                                    :description => "It's switchable, too!",
                                   :purchase_price => "10.0", 
                                   :weight => 20.0, 
                                   :manufacturer_product_code => 'ABC',
                                   :supplier_product_code => '12345')
      
      si = supplier.supply_items.first
      p = Product.new_from_supply_item(si)
      p.name.should == "Switchable Supply Item"
      p.weight.should == 20.0
      p.manufacturer_product_code.should == "ABC"
      p.supplier_product_code.should == "123"
      p.supplier.should == supplier
      p.save.should == true
      
      p.supply_item = supplier2.supply_items.first
      p.save.should == true
      p.supplier.should == supplier2
      p.supplier_product_code.should == "12345"
      p.supply_item.name.should == "Switchable Supply Item From Company 2"

    end
    
    it "should have its core data updated when its supply item has received an update to its core data (price or stock level)" do
      tax_class = TaxClass.create(:name => 'Test Tax Class', :percentage => "8.0")
      supplier = create_supplier("Some Company 1")
      items = [ {:name => "Some Supply Item",
                 :description => "Some stuff goes here.",
                 :purchase_price => "50.0", 
                 :weight => 20.0, 
                 :stock => 200,
                 :manufacturer_product_code => 'ABC',
                 :supplier_product_code => '123'},
                {:name => "Another Supply Item",
                 :description => "Some other stuff goes here.",
                 :purchase_price => "20.0", 
                 :weight => 10.0, 
                 :stock => 50,
                 :manufacturer_product_code => 'ABCDEF',
                 :supplier_product_code => '124'},
                ]
                
      items.each do |item_data|
        si = supplier.supply_items.create(item_data)
         p = Product.new_from_supply_item(si)
         p.save.should == true
      end
      
       
      SupplyItem.all.each do |si|
        si.purchase_price = si.purchase_price + 20
        si.stock = si.stock + 20
        si.save.should == true
      end
      
      Product.update_price_and_stock
      
      p1 = Product.where(:supplier_product_code => 123).first
      p2 = Product.where(:supplier_product_code => 124).first
      p1.purchase_price.should == BigDecimal("70.0")
      p1.stock.should == 220
      p2.purchase_price.should == BigDecimal("40.0")
      p2.stock.should == 70
    end

    it "should, when switching supply items, change its name to match the naming style of the supply item it is being switched to" do

      product = FactoryGirl.build(:product, :name => 'Product One')
      product.name.should == "Product One"
      supply_item1 = FactoryGirl.build(:supply_item, :name => 'Style of Supply Item One')
      supply_item2 = FactoryGirl.build(:supply_item, :name => 'Style of Supply Item Two')
      
      product.supply_item = supply_item1
      product.save
      product.name.should == "Style of Supply Item One"

      product.supply_item = supply_item2
      product.save
      product.name.should == "Style of Supply Item Two"
    end

  end
  
  describe "a componentized product" do
      before(:all) do
        @tax_class = FactoryGirl.build(:tax_class, :name => 'Test Tax Class', :percentage => "8.0") 
        @supplier = FactoryGirl.build(:alltron)
        array = [
          { 'name' => 'Some fast CPU', 'purchase_price' => "115.0",
            'weight' => 4.5 },
          { 'name' => 'Cool RAM', 'purchase_price' => "220.0",
            'weight' => 0.3 },
          { 'name' => 'An old Mainboard', 'purchase_price' => "80.0",
            'weight' => 1.2 },
          { 'name' => 'Semi-broken case with PSU', 'purchase_price' => "20.0",
            'weight' => 10.2 },
          { 'name' => 'Defective screen', 'purchase_price' => "200.0",
            'weight' => 2.8 }
        ]
        
        array.each do |si|
          options = {:supplier => @supplier, :tax_class => @tax_class }
          FactoryGirl.create(:supply_item, si.merge!(:supplier => @supplier, :tax_class => @tax_class))
        end
        
        SupplyItem.all.count.should == 5
    end
    
    after(:all) do
      SupplyItem.destroy_all
    end
    
    it "should consist of supply items as components" do
      p = FactoryGirl.build(:product)
      p.name = "Ye Olde Wooden PC"
      p.description = "A PC made of wood, with crappy components."
      p.supplier = @supplier
      
      p.add_component(SupplyItem.where(:name => 'Some fast CPU').first) 
      p.add_component(SupplyItem.where(:name => 'Cool RAM').first) 
      p.add_component(SupplyItem.where(:name => 'An old Mainboard').first) 
      p.add_component(SupplyItem.where(:name => 'Semi-broken case with PSU').first) 
      p.add_component(SupplyItem.where(:name => 'Defective screen').first) 
      p.save
      p.components.count.should == 5
    end

    it "should have a correct price, a total of constituent supply items" do
      MarginRange.destroy_all
      mr = FactoryGirl.create(:margin_range, :start_price => nil, :end_price => nil, :margin_percentage => 0.0)
      p = FactoryGirl.build(:product)
      
      p.name = "Ye Olde Wooden PC"
      p.description = "A PC made of wood, with crappy components."
      p.supplier = @supplier

      p.add_component(SupplyItem.where(:name => 'Some fast CPU').first) 
      p.add_component(SupplyItem.where(:name => 'Cool RAM').first) 
      p.add_component(SupplyItem.where(:name => 'An old Mainboard').first) 
      p.add_component(SupplyItem.where(:name => 'Semi-broken case with PSU').first) 
      p.add_component(SupplyItem.where(:name => 'Defective screen').first) 
      p.save
      p.purchase_price.should == (115 + 220 + 80 + 20 + 200) # The total of purchase prices
      p.gross_price.should == (115 + 220 + 80 + 20 + 200) # The same, since we set MarginRange to be 0.0 above
    end

    it "should have correct taxes and sales price, based on the totals of all the constituent supply items' purchase prices plus a total margin" do
      MarginRange.destroy_all
      mr = FactoryGirl.create(:margin_range, :start_price => 0, :end_price => 700, :margin_percentage => 10.0)
      p = FactoryGirl.build(:product)
      p.name = "Ye Olde Wooden PC"
      p.description = "A PC made of wood, with crappy components."
      p.supplier = @supplier
 
      p.add_component(SupplyItem.where(:name => 'Some fast CPU').first) 
      p.add_component(SupplyItem.where(:name => 'Cool RAM').first) 
      p.add_component(SupplyItem.where(:name => 'An old Mainboard').first) 
      p.add_component(SupplyItem.where(:name => 'Semi-broken case with PSU').first) 
      p.add_component(SupplyItem.where(:name => 'Defective screen').first)
      p.tax_class = @tax_class
      p.save
      p.taxes.should == 55.88
      p.taxed_price.should == 754.38
    end
    
    it "should be affected by MarginRanges just like normal products" do
      MarginRange.destroy_all
      mr = FactoryGirl.create(:margin_range, :start_price => 0, :end_price => 700, :margin_percentage => 10.0)
      p = FactoryGirl.build(:product)
      p.name = "Ye Olde Wooden PC"
      p.description = "A PC made of wood, with crappy components."
      p.supplier = @supplier
      
      p.add_component(SupplyItem.where(:name => 'Some fast CPU').first) 
      p.add_component(SupplyItem.where(:name => 'Cool RAM').first) 
      p.add_component(SupplyItem.where(:name => 'An old Mainboard').first) 
      p.add_component(SupplyItem.where(:name => 'Semi-broken case with PSU').first) 
      p.add_component(SupplyItem.where(:name => 'Defective screen').first) 
      p.save
      total = 115 + 220 + 80 + 20 + 200
      p.purchase_price.should == total # The total of purchase prices
      p.gross_price.should == total + ((total / 100.0) * mr.margin_percentage)
    end
    
  end # end componentized product
  
  
end
