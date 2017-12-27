require 'spec_helper'

describe ApplicationHelper, type: :helper do
  describe "display prices" do
    it "should round prices if rounding is set" do
      price = 150.22
      pretty_price(price, "CHF").should == "CHF 150.22"

      price = 150.22
      pretty_price(price, "CHF", true).should == "CHF 150.22"

      price = BigDecimal.new("150.22")
      pretty_price(price, "CHF").should == "CHF 150.20"

      price = BigDecimal.new("150.22")
      pretty_price(price, "CHF", false).should == "CHF 150.22"

      # Let's try some tricky things
      price = BigDecimal.new("150.00392")
      pretty_price(price, "CHF").should == "CHF 150.00" 

      price = BigDecimal.new("150.03392")
      pretty_price(price, "CHF").should == "CHF 150.05" 

      price = BigDecimal.new("150.05392")
      pretty_price(price, "CHF").should == "CHF 150.05" 
     

    end
  end

end
