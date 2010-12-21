class Category < ActiveRecord::Base
  has_and_belongs_to_many :products
  belongs_to :supplier
  
  #acts_as_tree :order => "name"
  
  acts_as_nested_set :order => "name"
  

  def fully_qualified_name
    trail = ""
    for cat in ancestors
      trail += cat.name 
      trail += " >> "
    end
    trail += name
    return trail
  end
  
  # Abstraction so we can switch out better_nested_set for something
  # else if it becomes necessary. Returns the category and all its
  # ancestors up to the root of the tree or graph.
  def ancestor_chain
    self_and_ancestors
  end

end
