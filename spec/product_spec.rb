require 'spec_helper'

describe Product do
  context "without tax class" do

    it "should not be saved" do
      p = Product.new
      p.name = "Foo"
      p.description = "Bar"
      result = p.save
      result.should == false
    end
  end
  
  context "with tax class" do
    it "should be saved" do
      p = Product.new
      p.name = "Foo"
      p.description = "Bar"
      p.tax_class = TaxClass.create(:name => 'Some Name', :percentage => 5.5)
      p.save.should == true
    end
  end

end