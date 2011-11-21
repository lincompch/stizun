# encoding: utf-8

require 'spec_helper'

describe Order do
  
  before(:each) do
    @tax_class = TaxClass.create(:name => 'Test Tax Class', :percentage => 8.0)
    TaxClass.all.count.should == 1
    
    @supplier = Supplier.create(:name => 'Test Supplier', :shipping_rate => ShippingRate.get_default)
    Country.create(:name => "Somewhereland")
    @address = Address.new(:street => 'Foo',
                  :firstname => 'Foo',
                  :lastname => 'Bar',
                  :postalcode => '1234',
                  :city => 'Somewhere',
                  :email => 'lala@lala.com',
                  :country => Country.first)    
    @address.save.should == true
    
    p = Product.new(
        :name => 'Test 1',
        :description => 'Foo',
        :purchase_price => 120.0,
        :margin_percentage => 5.0,
        :weight => 5.0,
        :supplier => @supplier,
        :tax_class => @tax_class)
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
    
  end
end