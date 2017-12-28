require 'spec_helper'

describe StaticDocument do
  
  before(:all) do
    MarginRange.destroy_all
    mr0 = FactoryGirl.build(:margin_range)
    mr0.start_price = nil
    mr0.end_price = nil
    mr0.margin_percentage = 5.0
    mr0.save
  
    # Why doesn't DatabaseCleaner do its job properly?
    TaxClass.destroy_all
    tax_class = FactoryGirl.create(:tax_class, {:percentage => "8.2"})
    
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

    # DatabaseCleaner or something seems to mess up these things royally on some machines, but not on others.
    # That's why we have to test explictly (what a waste of time!)
    sc = ShippingCalculator.get_default
    expect(sc.tax_class.percentage.to_f).to eq 8.2
    expect(sc.name).to eq 'For Testing Rounding'

    @supplier = FactoryGirl.create(:supplier)
    
    Country.create(:name => "Somewhereland")
    @address = Address.new(:street => 'Foo',
                  :firstname => 'Foo',
                  :lastname => 'Bar',
                  :postalcode => '1234',
                  :city => 'Somewhere',
                  :email => 'lala@lala.com',
                  :country => Country.first)    
    expect(@address.save).to eq true
    
    # Again, DatabaseCleaner does not seem to be able to clean up after itself properly
    Product.destroy_all
    p1 = Product.new(:name => "foo",  :manufacturer_product_code => 'bar124', :description => "bar", :weight => 5.5, :supplier => @supplier, :tax_class => tax_class, :purchase_price => "118.27", :direct_shipping => true, :is_available => true)
    expect(p1.save).to eq true
    p2 = Product.new(:name => "foo 2", :manufacturer_product_code => 'bar123', :description => "bar 2", :weight => 10.0, :supplier => @supplier, :tax_class => tax_class, :purchase_price => "236.22", :direct_shipping => true, :is_available => true)
    expect(p2.save).to eq true

  end


  context "the product involved" do
    it "should not round its gross price" do
      expect(Product.where(:name => 'foo').first.gross_price.to_s).to eq "124.1835"
    end

    it "should not round its taxes" do
      expect(Product.where(:name => 'foo').first.taxes.to_s).to eq "10.183047"
    end
  end
  
  context "when created from a dynamic document" do

    it "should round amounts (but not taxes) and keep the same rounded prices when creating static documents" do
      c = Cart.new
      c.add_product(Product.where(:name => 'foo').first)
      c.add_product(Product.where(:name => 'foo 2').first)
      c.save
      expect(c.lines.count).to eq 2

      expect(c.shipping_taxes.to_s).to eq "1.64"
      expect(c.shipping_cost.to_s).to eq "20.0"
      expect(c.total_taxed_shipping_price.to_s).to eq "21.64"


      expect(c.lines[0].taxed_price.to_s).to eq "134.35"
      expect(c.lines[0].gross_price.to_s).to eq "124.1835"
      expect(c.lines[0].price.to_s).to eq "124.2"
      expect(c.lines[0].taxes.to_s).to eq "10.183047"

      expect(c.lines[1].taxed_price.to_s).to eq "268.35"
      expect(c.lines[1].gross_price.to_s).to eq "248.031"
      expect(c.lines[1].price.to_s).to eq "248.05"
      expect(c.lines[1].taxes.to_s).to eq "20.338542"

      expect(c.products_taxed_price.to_s).to eq "402.7"
      expect(c.products_price.to_s).to eq "372.25"
      expect(c.taxed_price.to_s).to eq "424.34"
      expect(c.taxes.to_s).to eq "30.521589"
      expect(c.total_taxed_shipping_price.to_s).to eq "21.64"

      o = Order.new_from_cart(c)
      o.shipping_address = Address.first
      o.billing_address = Address.first
      expect(o.save).to eq true

      expect(o.shipping_taxes.to_s).to eq "1.64"
      expect(o.shipping_cost.to_s).to eq "20.0"
      expect(o.total_taxed_shipping_price.to_s).to eq "21.64"

      expect(o.lines[0].taxed_price.to_s).to eq "134.35"
      expect(o.lines[0].gross_price).to eq c.lines[0].gross_price # The same since we're at qty = 1
      expect(o.lines[0].single_untaxed_price).to eq c.lines[0].gross_price # The same since we're at qty = 1
      expect(o.lines[0].single_price.to_s).to eq "134.35"
      expect(o.lines[0].taxes.to_s).to eq "10.183047"

      expect(o.lines[1].taxed_price.to_s).to eq "268.35"
      expect(o.lines[1].gross_price).to eq c.lines[1].gross_price # The same since we're at qty = 1
      expect(o.lines[1].single_untaxed_price).to eq c.lines[1].gross_price # The same since we're at qty = 1
      expect(o.lines[1].single_price.to_s).to eq "268.35"
      expect(o.lines[1].taxes.to_s).to eq "20.338542"

      expect(o.products_taxed_price.to_s).to eq "402.7"
      expect(o.taxed_price.to_s).to eq "424.34"
      expect(o.taxes.to_s).to eq "30.521589"

    end


    # Many multiplications could trigger accumulated rounding errors, that's why
    # it's good to test for this.
    it "should still calculate totals correctly, even when there are many multiplications involved" do
      c = Cart.new
      c.add_product(Product.where(:name => 'foo').first, 863)
      c.save
      expect(c.lines.count).to eq 1

      expect(c.shipping_taxes.to_s).to eq "389.5"
      expect(c.shipping_cost.to_s).to eq "4750.0"
      expect(c.total_taxed_shipping_price.to_s).to eq "5139.5"

      expect(c.lines[0].taxed_price.to_s).to eq "115958.35"
      expect(c.lines[0].gross_price.to_s).to eq "107170.3605"
      expect(c.lines[0].price.to_s).to eq "107170.35"
      expect(c.lines[0].taxes.to_s).to eq "8787.969561"

      expect(c.products_taxed_price.to_s).to eq "115958.35"
      expect(c.products_price.to_s).to eq "107170.35"
      
      expect(c.taxed_price.to_s).to eq "121097.85"
      expect(c.taxes.to_s).to eq "8787.969561"

      o = Order.new_from_cart(c)
      o.shipping_address = Address.first
      o.billing_address = Address.first
      expect(o.save).to eq true
 
      expect(o.shipping_taxes.to_s).to eq "389.5"
      expect(o.shipping_cost.to_s).to eq "4750.0"
      expect(o.total_taxed_shipping_price.to_s).to eq "5139.5"

      expect(o.lines[0].taxed_price).to eq c.lines[0].taxed_price
      expect(o.lines[0].gross_price).to eq c.lines[0].gross_price
      expect(o.lines[0].taxes).to eq c.lines[0].taxes

      expect(o.products_taxed_price).to eq c.products_taxed_price
      expect(o.taxed_price).to eq c.taxed_price
      expect(o.taxes).to eq c.taxes
    end

  end
end
