# encoding: utf-8

require 'spec_helper'

describe Address do

  before(:each) do
    Country.create(:name => "Somewhereland")
  end

   it "should disallow PO boxes in the address field if system is so configured" do



      a = Address.new
      a.firstname = "first"
      a.lastname = "last"
      a.street = "P.O. Box"
      a.city = "blah"
      a.postalcode = "blah"
      a.email = "foo@bar.com"
      a.country = Country.first
      expect(a.save).to eq true

      ConfigurationItem.create(:key => "disallow_pobox_in_addresses", :value => "1")
      b = Address.new
      b.firstname = "first"
      b.lastname = "last"
      b.street = "P.O. Box"
      b.city = "blah"
      b.postalcode = "blah"
      b.email = "foo@bar.com"
      b.country = Country.first
      expect(b.save).to eq false
      b.street = "postfach"
      expect(b.save).to eq false
      b.street = "boîte postale"
      expect(b.save).to eq false
      b.street = "case postale"
      expect(b.save).to eq false
      b.street = "somewherestreet"
      expect(b.save).to eq true
    end

end
