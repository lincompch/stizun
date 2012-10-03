
require 'spec_helper'

describe CategoryDispatcher do
  
  before(:each) do
    CategoryDispatcher.destroy_all
  end

  it "should require three category levels to work" do
    category_dispatcher = FactoryGirl.create(:category_dispatcher)
    category_dispatcher.level_01 = nil
    category_dispatcher.save.should == false
    category_dispatcher.level_01 = "foo"
    category_dispatcher.save.should == true
  end


  it "should slot things into a target category" do
    category_dispatcher = FactoryGirl.create(:category_dispatcher)
    category_dispatcher.level_01 = "Root Category"
    category_dispatcher.level_02 = "Second-level Category"
    category_dispatcher.level_03 = "Third-level Category"
    category_dispatcher.save

    category1 = FactoryGirl.create(:category, {:name => "Root Category"})
    category2 = FactoryGirl.create(:category, {:name => "Second-level Category"})
    category3 = FactoryGirl.create(:category, {:name => "Third-level Category"})

    category2.parent = category1
    category3.parent = category2
    category2.save
    category3.save

    category_dispatcher.categories = [category3]
    category_dispatcher.save

    CategoryDispatcher.dispatch(["Root Category", "Second-level Category", "Third-level Category"]).should == [category3]
  end

  it "should not slot things anyhwere if the target is not set" do
    category_dispatcher = FactoryGirl.create(:category_dispatcher)
    category_dispatcher.level_01 = "Root Category"
    category_dispatcher.level_02 = "Second-level Category"
    category_dispatcher.level_03 = "Third-level Category"
    category_dispatcher.categories = []
    category_dispatcher.save

    category1 = FactoryGirl.create(:category, {:name => "Root Category"})
    category2 = FactoryGirl.create(:category, {:name => "Second-level Category"})
    category2.parent = category1
    category2.save

    CategoryDispatcher.dispatch(["Root Category", "Second-level Category", "Third-level Category"]).should == false
  end

  it "should not slot things anyhwere if there is no dispatcher for that combination" do
    category_dispatcher = FactoryGirl.create(:category_dispatcher)
    category_dispatcher.level_01 = "Root Category"
    category_dispatcher.level_02 = "Not a Second-level Category"
    category_dispatcher.level_03 = "Third-level Category"
    category_dispatcher.save

    category1 = FactoryGirl.create(:category, {:name => "Root Category"})
    category2 = FactoryGirl.create(:category, {:name => "Second-level Category"})
    category3 = FactoryGirl.create(:category, {:name => "Third-level Category"})

    category2.parent = category1
    category3.parent = category2
    category2.save
    category3.save
    category_dispatcher.categories = [category3]
    category_dispatcher.save

    CategoryDispatcher.dispatch(["Root Category", "Second-level Category", "Third-level Category"]).should == false
  end

  it "should determine the unique combinations of categories and levels for a supplier" do

    s = FactoryGirl.create(:supplier, :name => 'CategoryDispatcherTest')
    s.supply_items.create(:name => 'Foo', :category01 => 'Hund',
                                         :category02 => 'Katze',
                                         :category03 => 'Maus')

    # Second item with the same categories -- should not create an extra combination!
    s.supply_items.create(:name => 'Foo 2', :category01 => 'Hund',
                                            :category02 => 'Katze',
                                            :category03 => 'Maus')
  
    s.supply_items.create(:name => 'Foo 2', :category01 => 'Hund',
                                            :category02 => 'Katze',
                                            :category03 => 'Maus')

    s.supply_items.create(:name => 'Foo 2', :category01 => 'One',
                                            :category02 => 'Two',
                                            :category03 => 'Three')

    s.supply_items.create(:name => 'Foo 2', :category01 => 'Four',
                                            :category02 => 'Five',
                                            :category03 => 'Six')


    CategoryDispatcher.create_unique_combinations_for(s)
    s.category_dispatchers.group(:level_01, :level_02, :level_03).count.should == {
        ["Hund", "Katze", "Maus"]=> 1,
        ["One", "Two", "Three"]=> 1,
        ["Four", "Five", "Six"]=> 1
    }
  end
end
