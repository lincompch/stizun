require 'spec_helper'

describe Category do
  
  describe 'find or create category' do
    it 'should create a new category if it doesnt exist' do
      root = Category.create!(:name => "root")
      root.find_or_create_by_name("new category")
      Category.count.should == 2
    end
    
    it 'should return existing category with the name given' do
      root = Category.create!(:name => "root")
      child = Category.create!(:name => "child")
      child.parent = root
      child.save
      returned = root.find_or_create_by_name("child")
      Category.count.should == 2
      child.should == returned
    end
  end
  
  it 'should return all children categories to the last depth level' do
    root = Category.create!(:name => "root")
    child = Category.create!(:name => "child")
    child.parent = root
    child.save
    child2 = Category.create!(:name => "child2")
    child2.parent = child
    child2.save
    
    root.children_categories.flatten.should include(root, child, child2)
  end
end
