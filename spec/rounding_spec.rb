require 'spec_helper'

describe StaticDocument do
  
  before(:all) do
    mr0 = Fabricate.build(:margin_range)
    mr0.start_price = nil
    mr0.end_price = nil
    mr0.margin_percentage = 5.0
    mr0.save
  
    tax_class = Fabricate(:tax_class, {:percentage => 8.2})
    
    @sc = ShippingCalculatorBasedOnWeight.create(:name => 'For Testing Rounding')
    @sc.configuration.shipping_costs = []
    @sc.configuration.shipping_costs << {:weight_min => 0, :weight_max => 10000, :price => 10.0}
    @sc.tax_class = tax_class
    @sc.save
    
    ci = ConfigurationItem.where(:key => 'default_shipping_calculator_id').first
    if ci.nil?
      ci = ConfigurationItem.create(:key => 'default_shipping_calculator_id', :value => @sc.id)
    else
      ci.value = @sc.id
      ci.save
    end
    @supplier = Fabricate(:supplier)
    
    Country.create(:name => "Somewhereland")
    @address = Address.new(:street => 'Foo',
                  :firstname => 'Foo',
                  :lastname => 'Bar',
                  :postalcode => '1234',
                  :city => 'Somewhere',
                  :email => 'lala@lala.com',
                  :country => Country.first)    
    @address.save.should == true
    
    
    p1 = Product.new(:name => "foo", :description => "bar", :weight => 5.5, :supplier => @supplier, :tax_class => tax_class, :purchase_price => 118.27, :direct_shipping => true, :is_available => true)
    p1.save.should == true
    p2 = Product.new(:name => "foo 2", :description => "bar 2", :weight => 10.0, :supplier => @supplier, :tax_class => tax_class, :purchase_price => 236.22, :direct_shipping => true, :is_available => true)
    p2.save.should == true
  end


  context "the product involved" do
    it "should not round its gross price" do
      Product.first.gross_price.to_s.should == "124.1835"
    end

    it "should not round its taxes" do
      Product.first.taxes.to_s.should == "10.183047"
    end
  end
  
  context "when created from a dynamic document" do

    it "should round amounts (but not taxes) and keep the same rounded prices when creating static documents" do
      c = Cart.new
      c.add_product(Product.where(:name => 'foo').first)
      c.add_product(Product.where(:name => 'foo 2').first)
      c.save
      c.lines.count.should == 2

      c.shipping_taxes.to_s.should == "1.64"
      c.shipping_cost.to_s.should == "20.0"
      c.total_taxed_shipping_price.to_s.should == "21.64"


      c.lines[0].taxed_price.to_s.should == "134.35"
      c.lines[0].gross_price.to_s.should == "124.1835"
      c.lines[0].price.to_s.should == "124.2"
      c.lines[0].taxes.to_s.should == "10.183047"

      c.lines[1].taxed_price.to_s.should == "268.35"
      c.lines[1].gross_price.to_s.should == "248.031"
      c.lines[1].price.to_s.should == "248.05"
      c.lines[1].taxes.to_s.should == "20.338542"

      c.products_taxed_price.to_s.should == "402.7"
      c.products_price.to_s.should == "372.25"
      c.taxed_price.to_s.should == "424.34"
      c.taxes.to_s.should == "30.521589"
      c.total_taxed_shipping_price.to_s.should == "21.64"

      # TODO from here
      o = Order.new_from_cart(c)
      o.shipping_address = Address.first
      o.billing_address = Address.first
      o.save.should == true

      o.shipping_taxes.to_s.should == "1.64"
      o.shipping_cost.to_s.should == "20.0"
      o.total_taxed_shipping_price.to_s.should == "21.64"

      o.lines[0].taxed_price.to_s.should == "134.35"
      o.lines[0].single_price.to_s.should == "134.4385"
      o.lines[0].gross_price.to_s.should == "124.25"
      o.lines[0].single_untaxed_price.to_s.should == "124.25"
      o.lines[0].taxes.to_s.should == "10.1885"

      o.lines[1].taxed_price.to_s.should == "268.45"
      o.lines[1].single_price.to_s.should == "268.45"
      o.lines[1].gross_price.to_s.should == "248.1"
      o.lines[1].single_untaxed_price.to_s.should == "248.1"
      o.lines[1].taxes.to_s.should == "20.3442"

      o.products_taxed_price.to_s.should == "402.8827"
      o.taxed_price.to_s.should == "424.5227"
      o.taxes.to_s.should == "30.5327"

    end


    # Many multiplications could trigger accumulated rounding errors, that's why
    # it's good to test for this.
    it "should still calculate totals correctly, even when there are many multiplications involved" do
      c = Cart.new
      c.add_product(Product.where(:name => 'foo').first, 863)
      c.save
      c.lines.count.should == 1

      c.shipping_taxes.to_s.should == "389.5"
      c.shipping_cost.to_s.should == "4750.0"
      c.total_taxed_shipping_price.to_s.should == "5139.5"

      c.lines[0].taxed_price.to_s.should == "116020.4255"
      c.lines[0].gross_price.to_s.should == "107227.75"
      c.lines[0].price.to_s.should == "107227.75"
      c.lines[0].taxes.to_s.should == "8792.6755"

      c.products_taxed_price.to_s.should == "116020.4255"
      c.products_price.to_s.should == "107227.75"
      
      c.taxed_price.to_s.should == "121159.9255"
      c.taxes.to_s.should == "8792.6755"

      o = Order.new_from_cart(c)
      o.shipping_address = Address.first
      o.billing_address = Address.first
      o.save.should == true

      o.shipping_taxes.to_s.should == "389.5"
      o.shipping_cost.to_s.should == "4750.0"
      o.total_taxed_shipping_price.to_s.should == "5139.5"

      o.lines[0].taxed_price.to_s.should == "116020.4255"
      o.lines[0].gross_price.to_s.should == "107227.75"
      o.lines[0].taxes.to_s.should == "8792.6755"

      o.products_taxed_price.to_s.should == "116020.4255"
      o.taxed_price.to_s.should == "121159.9255"
      o.taxes.to_s.should == "8792.6755"
    end

  end
end
