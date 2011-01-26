require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Component Products", %q{
  Componentized products consist of a product that has one or more
  supply items. The product price is created from the sum of
  the component prices (and their quantities)
} do

  
  background do
    create_supply_items.count.should > 0
    
  end
  
  scenario "Gimme a category" do

  end
  
end
