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
      expect(@sc.save).to eq true
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
    expect(address.save).to eq true


    p = Product.new(:name => "foo", :description => "bar", :manufacturer_product_code => "bar", :weight => 5.5, :supplier => supplier, :tax_class => tax_class2, :purchase_price => BigDecimal.new("120.0"), :direct_shipping => true, :is_available => true)
    expect(p.save).to eq true

  end

  describe "a normal order" do

    it "should be created from a cart or other dynamic document" do
      c = Cart.new
      c.add_product(Product.first)
      c.save
      o = Order.new_from_cart(c)
      o.billing_address = Address.first
      expect(o.save).to eq true
    end

    it "should report the same totals as the dynamic order it came from" do
      c = Cart.new
      tc = FactoryGirl.create(:tax_class, {:percentage => "8.0"})
      product = FactoryGirl.create(:product, {:purchase_price => BigDecimal.new("100.0"), :tax_class => tc})
      product2 = FactoryGirl.create(:product, {:purchase_price => BigDecimal.new("250.0"), :tax_class => tc})

      c.add_product(product)
      c.add_product(product2)

      expect(c.lines[0].taxed_price.to_f).to eq 113.4
      expect(c.lines[1].taxed_price.to_f).to eq 283.50

      expect(c.total_taxed_shipping_price.to_f).to eq 11.0
      expect(c.products_taxed_price.to_f).to eq 396.9 # 113.40 + 283.50
      expect(c.taxed_price.to_f).to eq 407.9

      o = Order.new_from_cart(c)
      o.billing_address = Address.first
      o.save


      expect(o.lines[0].taxed_price.to_f).to eq 113.4
      expect(o.lines[1].taxed_price.to_f).to eq 283.50

      expect(o.total_taxed_shipping_price.to_f).to eq 11.0
      expect(o.products_taxed_price.to_f).to eq 396.9

      expect(o.taxed_price.to_f).to eq 407.9
    end
    
    it "should cancel its invoice when it is cancelled itself" do   
      c = Cart.new
      c.add_product(Product.first)
      c.save
      
      o = Order.new_from_cart(c)
      o.billing_address = Address.first
      expect(o.save).to eq true
      
      Invoice.create_from_order(o)
      
      o.cancel
      expect(o.invoice.status_constant).to eq Invoice::CANCELED
    end
    
    it "should refer to the correct invoice when an invoice is created from an order" do
      c = Cart.new
      c.add_product(Product.first)
      c.save
      
      o = Order.new_from_cart(c)
      o.billing_address = Address.first
      expect(o.save).to eq true
      
      i = Invoice.create_from_order(o)
      expect(i.valid?).to eq true
      expect(i.new_record?).to eq false
      expect(i.order_id).to eq o.id
      expect(o.invoice).to eq i
    end

    it "should have no shipping cost with n items, according to the shop's configuration" do
      ConfigurationItem.create(:key => "free_shipping_minimum_items", :value =>3)
      
      product = Product.where(:name => 'foo').first
      c = Cart.new
      c.add_product(product)
      c.save
      
      
      # Right now it still has the default shipping cost      
      expect(c.shipping_cost).to eq BigDecimal.new("10.0")
      expect(c.shipping_taxes).to eq BigDecimal.new("1.0")
            
      c.add_product(product)
      expect(c.shipping_cost).to eq BigDecimal.new("20.0")
      expect(c.shipping_taxes).to eq BigDecimal.new("2.0")      
      
      c.add_product(product)
      expect(c.shipping_cost).to eq BigDecimal.new("0.0")
      expect(c.shipping_taxes).to eq BigDecimal.new("0.0")
    end
		
    it "should have no shipping cost starting at a certain order value, according to the shop's configuration" do
      ConfigurationItem.create(:key => "free_shipping_minimum_amount", :value => 300)

      product = Product.where(:name => 'foo').first      
      c = Cart.new
      c.add_product(product)
      c.save

      # Right now it still has the default shipping cost
      expect(c.shipping_cost).to eq BigDecimal.new("10.0")
      expect(c.shipping_taxes).to eq BigDecimal.new("1.0")

      # Now the value goes over 300, thus triggering free shipping
      c.add_product(product)
      c.add_product(product)
      expect(c.shipping_cost).to eq BigDecimal.new("0.0")
      expect(c.shipping_taxes).to eq BigDecimal.new("0.0")
    end

    it "should get its shipping cost passed on correctly from a shopping cart" do
      ConfigurationItem.create(:key => "free_shipping_minimum_amount", :value => 300)
      c = Cart.new
      c.add_product(Product.first)
      c.add_product(Product.first)
      c.add_product(Product.first)
      c.save

      o = Order.new_from_cart(c)
      expect(o.shipping_cost).to eq BigDecimal.new("0.0")
      expect(o.shipping_taxes).to eq BigDecimal.new("0.0")
    end
 

    it "should auto-cancel itself if no payment has arrived 10 days after ordering, and if it's set to auto-cancel itself" do
      product = Product.where(:name => 'foo').first
      c = Cart.new
      c.add_product(product)
      c.save

      o = Order.new_from_cart(c)
      o.billing_address = Address.first
      o.auto_cancel = true
      expect(o.save).to eq true
      o.invoice_order

      c2 = Cart.new
      c2.add_product(product)
      c2.save

      o2 = Order.new_from_cart(c2)
      o2.billing_address = Address.first
      expect(o2.save).to eq true
      o2.invoice_order

      o.update_attributes({:created_at => (DateTime.now - 15.days)})
      o.save

      Order.process_automatic_cancellations
      o.reload
      expect(o.status_constant).to eq Order::CANCELED
      expect(o2.reload.status_constant).to eq Order::AWAITING_PAYMENT

    end

    it "should not auto-cancel itself it's not set to auto-cancel" do
      product = Product.where(:name => 'foo').first
      c = Cart.new
      c.add_product(product)
      c.save

      o = Order.new_from_cart(c)
      o.billing_address = Address.first
      o.auto_cancel = false
      expect(o.save).to eq true
      o.invoice_order

      c2 = Cart.new
      c2.add_product(product)
      c2.save

      o.update_attributes({:created_at => (DateTime.now - 15.days)})
      o.save

      Order.process_automatic_cancellations
      o.reload
      expect(o.status_constant).to eq Order::AWAITING_PAYMENT # Same as when it was submitted
    end


    it "should e-mail customers when it auto-cancels itself" do
      product = Product.where(:name => 'foo').first
      c = Cart.new
      c.add_product(product)
      c.save

      o = Order.new_from_cart(c)
      o.billing_address = Address.first
      o.auto_cancel = true
      expect(o.save).to eq true
      o.invoice_order

      o.update_attributes({:created_at => (DateTime.now - 15.days)})
      o.save

      ActionMailer::Base.deliveries.clear
      Order.process_automatic_cancellations

      emails = ActionMailer::Base.deliveries
      expect(emails.count).to eq 1 # The invoice counts as well!
      expect(emails[0].subject).to eq "[Local Shop] Stornierung: Ihre Bestellung wurde wegen ausstehender Zahlung storniert"
      expect(emails[0].body).to match(/.*storniert worden.*/)
    end

  end

end
