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
      child = Category.create!(:name => "child", :parent => root)
      returned = root.find_or_create_by_name("child", 1)
      Category.count.should == 2
      child.should == returned
    end
  end

  it 'should return all children categories to the last depth level' do
    root = Category.create!(:name => "root")
    child = Category.create!(:name => "child", :parent => root)
    child2 = Category.create!(:name => "child2", :parent => child)

    root.children_categories.flatten.should include(root, child, child2)
  end

  describe 'generate_ancestry' do
    it 'should generate ancestry string for new category' do
      category = Category.new(:name => "Test")
      category.should_receive(:generate_ancestry)
      category.save!
    end

    it 'should generate ancestry string with proper order' do
      category = Category.create!(:name => "Test")
      child = Category.create!(:name => "child", :parent => category)
      category.ancestry.should == "#{category.id}"
      child.save!
      child.ancestry.should == "#{category.id}/#{child.id}"
    end

  end

end

