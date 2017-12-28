# encoding: utf-8

require 'spec_helper'
require_relative '../lib/jet_util'

describe JetUtil do
  before(:each) do
    expect(SupplyItem.count).to eq 0
    Supplier.find_or_create_by(:name => "jET Schweiz IT AG")
  end

  describe "importing supply items from CSV" do

    it "should import 101 items" do
      JetTestHelper.import_from_file(Rails.root + "spec/data/jet_products.utf8.csv")
      expect(SupplyItem.count).to eq 101
      supplier = Supplier.where(:name => 'jET Schweiz IT AG').first
    end

    it "should import product description URLs from CSV files, if they are present" do
      JetTestHelper.import_from_file(Rails.root + "spec/data/jet_products.utf8.csv")
      supplier = Supplier.where(:name => 'jET Schweiz IT AG').first
      expect(supplier.supply_items.first.description_url).to eq "http://www.testdescription.com"

    end

    it "should import some EAN codes for supply items" do
      JetTestHelper.import_from_file(Rails.root + "spec/data/jet_products.utf8.csv")
      expect(SupplyItem.count).to eq 101
      expect(SupplyItem.all.collect(&:ean_code).uniq).to_not be([nil]) # Not all items have EAN codes, only 97 do
    end


  end

end
