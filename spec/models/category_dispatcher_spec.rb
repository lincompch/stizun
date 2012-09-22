
require 'spec_helper'

describe CategoryDispatcher do
  
  before(:all) do


    @category_dispatcher = FactoryGirl.create(:category_dispatcher)
  end
  

  it "should require three category levels to work" do
    @category_dispatcher.level_01 = nil
    @category_dispatcher.save.should == false
    @category_dispatcher.level_01 = "foo"
    @category_dispatcher.save.should == true
  end

end
