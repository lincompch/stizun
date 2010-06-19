class Category < ActiveRecord::Base
  has_and_belongs_to_many :products
  
  acts_as_tree :order => "name"

  def fully_qualified_name
    trail = ""
    for cat in ancestors
      trail += cat.name 
      trail += " >> "
    end
    trail += name
    return trail
  end

end
