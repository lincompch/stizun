# encoding: utf-8

require 'spec_helper'

describe Product do

  describe "the system in general" do
    it "should have some supply items" do
      @supplier = create_supplier("Alltron AG")
      supply_items = create_supply_items(@supplier)
      expect(supply_items.count).to be > 0
    end
    
    it "should have a tax class" do
      @tax_class = TaxClass.create(:name => 'Test Tax Class', :percentage => "8.0")
      expect(TaxClass.where(:name => 'Test Tax Class', :percentage => "8.0").first).to_not be_nil
    end
  end
  
  describe "a product" do
    before(:each) do
      @tax_class = TaxClass.create(:name => 'Test Tax Class', :percentage => "8.0")
      @supplier = create_supplier("Alltron AG")
      supply_items = create_supply_items(@supplier)
      expect(supply_items.count).to be > 0 
      @suplier = Supplier.where(:name => 'Alltron AG').first
      p = Product.new
      p.tax_class = @tax_class
      p.name = "Something"
      p.description = "Some stuff"
      if Product.last
        mfg_code = "mfg #{Product.last.id + 1}"
      else
        mfg_code = "mfg 0"
      end
      p.manufacturer_product_code = mfg_code
      p.weight = 1.0
      p.supplier = @supplier
      expect(p.save).to eq true
    end

    
    it "should be able to retrieve a product picture and PDF if the respective URLs are valid" do
      download_dir = Rails.root + "tmp/downloads"
      system("mkdir -p #{download_dir}") unless Dir.exist?("tmp/downloads")
      p = FactoryGirl.build(:product)
      p.supplier = @supplier
      si = FactoryGirl.build(:supply_item)
      si.image_url = "https://www.google.ch/images/srpr/logo3w.png"
      si.pdf_url = "https://file-examples.com/wp-content/uploads/2017/10/file-sample_150kB.pdf"
      expect(si.save).to eq true
      
      p.supply_item = si
      if Product.last
        mfg_code = "mfg baz #{Product.last.id + 1}"
      else
        mfg_code = "mfg baz 0"
      end
      p.manufacturer_product_code = mfg_code
      expect(p.save).to eq true
      p.try_to_get_product_files
      
      image_path = "#{download_dir}/#{p.supply_item.id}_#{File.basename(si.image_url)}"
      pdf_path = "#{download_dir}/#{p.supply_item.id}_#{File.basename(si.pdf_url)}"
      puts image_path, pdf_path
      expect(File.exist?(image_path)).to eq true
      expect(File.exist?(pdf_path)).to eq true
    end
    
    it "should use the most specific margin range available to it for price calculation" do
      supplier = FactoryGirl.create(:supplier)

      product = FactoryGirl.build(:product)
      product.purchase_price = "100.0"
      product.supplier = supplier
      expect(product.save).to eq true

      MarginRange.destroy_all # Sometimes FactoryGirl.build goes a little overboard creating associated records

      # default system-wide margin range
      mr0 = FactoryGirl.build(:margin_range)
      mr0.start_price = nil
      mr0.end_price = nil
      mr0.margin_percentage = 10.0
      expect(mr0.save).to eq true

      expect(product.margin_percentage).to eq 10.0
      
      mr1 = FactoryGirl.build(:margin_range)
      mr1.start_price = nil
      mr1.end_price = nil
      mr1.supplier = supplier
      mr1.margin_percentage = 20.0
      expect(mr1.save).to eq true
      supplier.reload
      expect(product.margin_percentage).to eq 20.0

      mr2 = FactoryGirl.build(:margin_range)
      mr2.start_price = nil
      mr2.end_price = nil
      mr2.product = product
      mr2.margin_percentage = 30.0
      expect(mr2.save).to eq true
      product.reload

      expect(product.margin_percentage).to eq 30.0

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
      expect(p.name).to eq "Switchable Supply Item"
      expect(p.weight).to eq 20.0
      expect(p.manufacturer_product_code).to eq "ABC"
      expect(p.supplier_product_code).to eq "123"
      expect(p.supplier).to eq supplier
      expect(p.save).to eq true
      
      p.supply_item = supplier2.supply_items.first
      expect(p.save).to eq true
      expect(p.supplier).to eq supplier2
      expect(p.supplier_product_code).to eq "12345"
      expect(p.supply_item.name).to eq "Switchable Supply Item From Company 2"

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
         expect(p.save).to eq true
      end
      
       
      SupplyItem.all.each do |si|
        si.purchase_price = si.purchase_price + 20
        si.stock = si.stock + 20
        expect(si.save).to eq true
      end
      
      Product.update_price_and_stock
      
      p1 = Product.where(:supplier_product_code => 123).first
      p2 = Product.where(:supplier_product_code => 124).first
      expect(p1.purchase_price).to eq BigDecimal("70.0")
      expect(p1.stock).to eq 220
      expect(p2.purchase_price).to eq BigDecimal("40.0")
      expect(p2.stock).to eq 70
    end

    it "should, when switching supply items, change its name to match the naming style of the supply item it is being switched to" do

      product = FactoryGirl.build(:product, :name => 'Product One')
      expect(product.name).to eq "Product One"
      supply_item1 = FactoryGirl.build(:supply_item, :name => 'Style of Supply Item One', :manufacturer_product_code => 'ABC123')
      supply_item2 = FactoryGirl.build(:supply_item, :name => 'Style of Supply Item Two', :manufacturer_product_code => 'ABC123')
      
      product.supply_item = supply_item1
      product.save
      expect(product.name).to eq "Style of Supply Item One"

      product.supply_item = supply_item2
      if product.save == false
        binding.pry
      end
      expect(product.save).to eq true
      expect(product.reload.name).to eq "Style of Supply Item Two"
    end


    it "should extract URLs from its own description and attach them to itself" do
      product = FactoryGirl.build(:product, :name => 'URLified product')
      product.description = "This product has a datasheet at http://www.example.com/product1 and its product manager can be reached at mailto:foo@example.com. Also, see http://www.example.com/about for company information"
      expect(product.save).to eq true
      expect(product.links.collect(&:url).include?("http://www.example.com/product1")).to be true
      expect(product.links.collect(&:url).include?("mailto:foo@example.com")).to eq false
      expect(product.links.collect(&:url).include?("http://www.example.com/about")).to eq true
    end

    it "should not extract URLs that are already there" do
      product = FactoryGirl.build(:product, :name => 'URLified product 2')
      product.description = "This product has a datasheet at http://www.example.com and its product manager can be reached at http://www.example.com . Also, see http://www.example.com for company information"
      expect(product.save).to eq true
      expect(product.links.collect(&:url).to_a).to eq ["http://www.example.com"]
      expect(product.links.count).to eq 1 
    end

    it "should ignore the punctuation at the end of URLs" do
      product = FactoryGirl.build(:product, :name => 'URLified product 2')
      product.description = "This product has a datasheet at http://www.example.com. And its product manager can be reached at http://www.example.com, or perhaps at http://www.example.com."
      expect(product.save).to eq true
      expect(product.links.collect(&:url).to_a).to eq ["http://www.example.com"]
      expect(product.links.count).to eq 1 
    end

    it "should, when switching supply items, add any new URLs it finds to the product" do

      product = FactoryGirl.build(:product, :name => 'Product One')
      expect(product.name).to eq "Product One"
      supply_item1 = FactoryGirl.build(:supply_item, :name => 'Supply Item One', :description => 'http://www.example.com', :manufacturer_product_code => 'ABC123')
      supply_item2 = FactoryGirl.build(:supply_item, :name => 'Supply Item Two', :description => 'http://www.other.example.com', :manufacturer_product_code => 'ABC123')
      
      product.supply_item = supply_item1
      product.save
      expect(product.links.count).to eq 1
      product.supply_item = supply_item2
      if product.save == false
        binding.pry
      end
      expect(product.save).to eq true
      expect(product.reload.links.count).to eq 2
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
          FactoryGirl.create(:supply_item, si.merge!(:supplier => @supplier))
        end
        
        expect(SupplyItem.all.count).to eq 5
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
      expect(p.components.count).to eq 5
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
      expect(p.purchase_price).to eq (115 + 220 + 80 + 20 + 200) # The total of purchase prices
      expect(p.gross_price).to eq (115 + 220 + 80 + 20 + 200) # The same, since we set MarginRange to be 0.0 above
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
      expect(p.taxes).to eq 55.88
      expect(p.taxed_price).to eq 754.38
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
      expect(p.purchase_price).to eq total # The total of purchase prices
      expect(p.gross_price).to eq total + ((total / 100.0) * mr.margin_percentage)
    end
    
  end # end componentized product
  
  
end
