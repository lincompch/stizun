require 'spec_helper'

describe StaticDocument do
  
  before(:all) do
    mr0 = Fabricate.build(:margin_range)
    mr0.start_price = nil
    mr0.end_price = nil
    mr0.margin_percentage = 5.0
    mr0.save
  
    tax_class = Fabricate(:tax_class, {:percentage => 8.2})
    
    @sc = ShippingCalculatorBasedOnWeight.create(:name => 'For Testing')
    @sc.configuration.shipping_costs = []
    @sc.configuration.shipping_costs << {:weight_min => 0, :weight_max => 10000, :price => 10.0}
    @sc.tax_class = tax_class
    @sc.save
    ConfigurationItem.create(:key => 'default_shipping_calculator_id', :value => @sc.id)

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
  
  context "when created from a dynamic document" do
    it "should not round any amounts, they should be passed on unrounded, to be rounded only in the view" do
      c = Cart.new
      c.add_product(Product.first)
      c.add_product(Product.last)
      c.save
      c.lines.count.should == 2

      c.shipping_taxes.to_s.should == "1.64"
      c.shipping_cost.to_s.should == "20.0"
      c.total_taxed_shipping_price.to_s.should == "21.64"

      c.lines[0].taxed_price.to_s.should == "134.366546999999998918"
      c.lines[0].gross_price.to_s.should == "124.183499999999999"
      c.lines[0].price.to_s.should == "124.183499999999999"
      c.lines[0].taxes.to_s.should == "10.183046999999999918"

      c.lines[1].taxed_price.to_s.should == "268.369542"
      c.lines[1].gross_price.to_s.should == "248.031"
      c.lines[1].price.to_s.should == "248.031"
      c.lines[1].taxes.to_s.should == "20.338542"

      c.products_taxed_price.to_s.should == "402.736088999999998918"
      c.products_price.to_s.should == "372.214499999999999"
      c.taxed_price.to_s.should == "424.376088999999998918"
      c.taxes.to_s.should == "30.521588999999999918"
      c.total_taxed_shipping_price.to_s.should == "21.64"

      o = Order.new_from_cart(c)
      o.shipping_address = Address.first
      o.billing_address = Address.first
      o.save.should == true

      o.shipping_taxes.to_s.should == "1.64"
      o.shipping_cost.to_s.should == "20.0"
      o.total_taxed_shipping_price.to_s.should == "21.64"

      o.lines[0].taxed_price.to_s.should == "134.366546999999998918"
      o.lines[0].single_price.to_s.should == "134.366546999999998918"
      o.lines[0].gross_price.to_s.should == "124.183499999999999"
      o.lines[0].single_untaxed_price.to_s.should == "124.183499999999999"
      o.lines[0].taxes.to_s.should == "10.183046999999999918"

      o.lines[1].taxed_price.to_s.should == "268.369542"
      o.lines[1].single_price.to_s.should == "268.369542"
      o.lines[1].gross_price.to_s.should == "248.031"
      o.lines[1].single_untaxed_price.to_s.should == "248.031"
      o.lines[1].taxes.to_s.should == "20.338542"

      o.products_taxed_price.to_s.should == "402.736088999999998918"
      o.taxed_price.to_s.should == "424.376088999999998918"
      o.total_taxes.to_s.should == "32.161588999999999918"
      o.taxes.to_s.should == "30.521588999999999918"

    end

    it "should still calculate unrounded totals correctly, even when there are many multiplications involved" do
      c = Cart.new
      c.add_product(Product.first, 863)
      c.save
      c.lines.count.should == 1

      c.shipping_taxes.to_s.should == "389.5"
      c.shipping_cost.to_s.should == "4750.0"
      c.total_taxed_shipping_price.to_s.should == "5139.5"


      c.lines[0].taxed_price.to_s.should == "115958.330060999999066234"
      c.lines[0].gross_price.to_s.should == "107170.360499999999137"
      c.lines[0].price.to_s.should == "107170.360499999999137"
      c.lines[0].taxes.to_s.should == "8787.969560999999929234"

      c.products_taxed_price.to_s.should == "115958.330060999999066234"
      c.products_price.to_s.should == "107170.360499999999137"

      c.taxed_price.to_s.should == "121097.830060999999066234"
      c.taxes.to_s.should == "8787.969560999999929234"

      o = Order.new_from_cart(c)
      o.shipping_address = Address.first
      o.billing_address = Address.first
      o.save.should == true

      o.shipping_taxes.to_s.should == "389.5"
      o.shipping_cost.to_s.should == "4750.0"
      o.total_taxed_shipping_price.to_s.should == "5139.5"

      o.lines[0].taxed_price.to_s.should == "115958.330060999999066234"
#      o.lines[0].single_price.to_s.should == ""
      o.lines[0].gross_price.to_s.should == "107170.360499999999137"
#      o.lines[0].single_untaxed_price.to_s.should == ""
      o.lines[0].taxes.to_s.should == "8787.969560999999929234"

      o.products_taxed_price.to_s.should == "115958.330060999999066234"
      o.taxed_price.to_s.should == "121097.830060999999066234"
#      o.total_taxes.to_s.should == ""
      o.taxes.to_s.should == "8787.969560999999929234"
    end

  end
end
