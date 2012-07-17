require 'spec_helper'

describe Order do
  
  before(:all) do
    mr0 = FactoryGirl.build(:margin_range)
    mr0.start_price = nil
    mr0.end_price = nil
    mr0.margin_percentage = 5.0
    mr0.save
  
    tax_class2 = TaxClass.where(:percentage => "10.0").first
    tax_class2 = FactoryGirl.create(:tax_class, {:percentage => "10.0"}) if tax_class2.nil?

    
    @sc = ShippingCalculatorBasedOnWeight.where(:name => 'For Testing Orders').first
    if @sc.nil?
      @sc = ShippingCalculatorBasedOnWeight.create(:name => 'For Testing Orders')
      @sc.configuration.shipping_costs = []
      @sc.configuration.shipping_costs << {:weight_min => 0, :weight_max => 10000, :price => 10.0}
      @sc.tax_class = tax_class2
      @sc.save.should == true
    end

    ci = ConfigurationItem.where(:key => 'default_shipping_calculator_id').first
    if ci.nil?
      ci = ConfigurationItem.create(:key => 'default_shipping_calculator_id', :value => @sc.id)
    else
      ci.value = @sc.id
      ci.save
    end

    supplier = FactoryGirl.create(:supplier)
    supplier.save
    
    Country.create(:name => "Somewhereland")
    address = Address.new(:street => 'Foo',
                  :firstname => 'Foo',
                  :lastname => 'Bar',
                  :postalcode => '1234',
                  :city => 'Somewhere',
                  :email => 'lala@lala.com',
                  :country => Country.first)    
    address.save.should == true
    
    
    p = Product.new(:name => "foo", :description => "bar", :weight => 5.5, :supplier => supplier, :tax_class => tax_class2, :purchase_price => BigDecimal.new("120.0"), :direct_shipping => true, :is_available => true)
    p.save.should == true
    
  end
  
  describe "a normal order" do
    
    it "should be created from a cart or other dynamic document" do
      c = Cart.new
      c.add_product(Product.first)
      c.save
      o = Order.new_from_cart(c)
      o.billing_address = Address.first
      o.save.should == true
    end

    it "should report the same totals as the dynamic order it came from" do
      c = Cart.new
      tc = FactoryGirl.create(:tax_class, {:percentage => "8.0"})
      product = FactoryGirl.create(:product, {:purchase_price => BigDecimal.new("100.0"), :tax_class => tc})
      product2 = FactoryGirl.create(:product, {:purchase_price => BigDecimal.new("250.0"), :tax_class => tc})

      c.add_product(product)
      c.add_product(product2)

      c.lines[0].taxed_price.to_f.should == 113.4
      c.lines[1].taxed_price.to_f.should == 283.50

      c.total_taxed_shipping_price.to_f.should == 11.0
      c.products_taxed_price.to_f.should == 396.9 # 113.40 + 283.50
      c.taxed_price.to_f.should == 407.9

      o = Order.new_from_cart(c)
      o.billing_address = Address.first
      o.save


      o.lines[0].taxed_price.to_f.should == 113.4
      o.lines[1].taxed_price.to_f.should == 283.50

      o.total_taxed_shipping_price.to_f.should == 11.0
      o.products_taxed_price.to_f.should == 396.9

      o.taxed_price.to_f.should == 407.9
    end
    
    it "should cancel its invoice when it is cancelled itself" do   
      c = Cart.new
      c.add_product(Product.first)
      c.save
      
      o = Order.new_from_cart(c)
      o.billing_address = Address.first
      o.save.should == true
      
      i = Invoice.create_from_order(o)
      
      o.cancel
      o.invoice.status_constant.should == Invoice::CANCELED
    end
    
    it "should refer to the correct invoice when an invoice is created from an order" do
      c = Cart.new
      c.add_product(Product.first)
      c.save
      
      o = Order.new_from_cart(c)
      o.billing_address = Address.first
      o.save.should == true
      
      i = Invoice.create_from_order(o)
      i.valid?.should == true
      i.new_record?.should == false
      i.order_id.should == o.id
      o.invoice.should == i
    end

    it "should have no shipping cost with n items, according to the shop's configuration" do
      ConfigurationItem.create(:key => "free_shipping_minimum_items", :value =>3)
      
      product = Product.where(:name => 'foo').first
      c = Cart.new
      c.add_product(product)
      c.save
      
      
      # Right now it still has the default shipping cost      
      c.shipping_cost.should == BigDecimal.new("10.0")
      c.shipping_taxes.should == BigDecimal.new("1.0")
            
      c.add_product(product)
      c.shipping_cost.should == BigDecimal.new("20.0")
      c.shipping_taxes.should == BigDecimal.new("2.0")      
      
      c.add_product(product)
      c.shipping_cost.should == BigDecimal.new("0.0")
      c.shipping_taxes.should == BigDecimal.new("0.0")
    end
		
    it "should have no shipping cost starting at a certain order value, according to the shop's configuration" do
      ConfigurationItem.create(:key => "free_shipping_minimum_amount", :value => 300)
      
      product = Product.where(:name => 'foo').first      
      c = Cart.new
      c.add_product(product)
      c.save

      # Right now it still has the default shipping cost
      c.shipping_cost.should == BigDecimal.new("10.0")
      c.shipping_taxes.should == BigDecimal.new("1.0")
            
      # Now the value goes over 300, thus triggering free shipping
      c.add_product(product)
      c.add_product(product)
      c.shipping_cost.should == BigDecimal.new("0.0")
      c.shipping_taxes.should == BigDecimal.new("0.0")
    end
    
    it "should get its shipping cost passed on correctly from a shopping cart" do
      ConfigurationItem.create(:key => "free_shipping_minimum_amount", :value => 300)
      c = Cart.new
      c.add_product(Product.first)
      c.add_product(Product.first)
      c.add_product(Product.first)
      c.save
      
      o = Order.new_from_cart(c)
      o.shipping_cost.should == BigDecimal.new("0.0")
      o.shipping_taxes.should == BigDecimal.new("0.0")
    end
    
  end

end
