require 'spec_helper'

describe Order do
  
  before(:all) do
    mr0 = Factory.build(:margin_range)
    mr0.start_price = nil
    mr0.end_price = nil
    mr0.margin_percentage = 5.0
    mr0.save
  
    @tax_class = Factory.create(:tax_class, {:percentage => 8.0})
    
    @shipping_rate = Factory.create(:shipping_rate, {:tax_class => @tax_class})
    @shipping_rate.shipping_costs.create(:price => 10.0, :weight_min => 0, :weight_max => 10000, :tax_class => @tax_class)

    @supplier = Factory.create(:supplier, :shipping_rate => @shipping_rate)
    @supplier.shipping_rate = @shipping_rate
    @supplier.save
    
    Country.create(:name => "Somewhereland")
    @address = Address.new(:street => 'Foo',
                  :firstname => 'Foo',
                  :lastname => 'Bar',
                  :postalcode => '1234',
                  :city => 'Somewhere',
                  :email => 'lala@lala.com',
                  :country => Country.first)    
    @address.save.should == true
    
    
    # For some reason, using FactoryGirl to create this breaks everything, it creates all associated
    # things along with it, ignores the @tax_class that we explicitly set and creates many unnecessary
    # suppliers and tax rates, which messes everything up completely.
    p = Product.new(:name => "foo", :description => "bar", :weight => 5.5, :supplier => @supplier, :tax_class => @tax_class, :purchase_price => 120.0, :direct_shipping => true, :is_available => true)
    p.save.should == true
    
  end
  
  describe "a normal order" do
    
    it "should be created from a cart" do
      c = Cart.new
      c.add_product(Product.first)
      c.save
      o = Order.new_from_cart(c)
      o.billing_address = Address.first
      o.save.should == true
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

      # Right now it still has the default shipping cost from the default shipping rate
      c.shipping_cost.should == BigDecimal.new("10.80")
      
      c.add_product(product)
      c.shipping_cost.should == BigDecimal.new("21.60")
      
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

      # Right now it still has the default shipping cost from the default shipping rate
      c.shipping_cost.should == BigDecimal.new("10.80")
      
      c.add_product(product)
      c.shipping_cost.should == BigDecimal.new("21.60")
      
      # Now the value goes over 300, thus triggering free shipping
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