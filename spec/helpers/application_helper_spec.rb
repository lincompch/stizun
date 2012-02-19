require 'spec_helper'

describe ApplicationHelper do
   
   describe 'display rss feed' do
      before(:each) do
        file = File.join("file://",Rails.root, "test", "fixtures", "feed.rss")
        FeedEntry.update_from_feed(file)
        @output = display_rss_feed()
      end
   
      it 'should return div with expected class' do      
         @output.should match /div class='rss-entries'/
      end
      
      it 'should contain the exact number of entries as the feed' do    
         @output.should match /<h4><a href=\'www.example.com\/1\'>Some example title 1<\/a><\/h4>/
         @output.should match /<h4><a href=\'www.example.com\/6\'>Some example title 6<\/a><\/h4>/
      end
      
      it 'should contain the exact number of entries as the feed when with limit' do 
         @output = display_rss_feed(2)
         @output.should match /<h4><a href=\'www.example.com\/1\'>Some example title 1<\/a><\/h4>/
         @output.should match /<h4><a href=\'www.example.com\/2\'>Some example title 2<\/a><\/h4>/
         @output.should_not match /<h4><a href=\'www.example.com\/6\'>Some example title 6<\/a><\/h4>/
      end
      
   end


  describe "display prices" do
    it "should round prices if rounding is set" do
      price = 150.22
      pretty_price(price, "CHF").should == "CHF 150.22"

      price = 150.22
      pretty_price(price, "CHF", true).should == "CHF 150.22"

      price = BigDecimal.new("150.22")
      pretty_price(price, "CHF").should == "CHF 150.25"

      price = BigDecimal.new("150.22")
      pretty_price(price, "CHF", false).should == "CHF 150.22"

    end
  end

end
