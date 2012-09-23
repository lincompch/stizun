class CategoryDispatcher < ActiveRecord::Base

  validates_presence_of :level_01, :level_02,:level_02
  belongs_to :target_category, :class_name => "Category"

  def self.dispatch(categories, options = {})
    self.validate_arguments(categories)
    # Find out if there is a configuration for this set of categories
    configuration = self.where(:level_01 => categories[0],
                               :level_02 => categories[1],
                               :level_03 => categories[2]).first
    if configuration.nil? or configuration.target_category.nil?
      return false
    else
      return configuration.target_category
    end
  end

  def find_candidate(categories)
    self.validate_arguments(categories)
    candidate = Category.where(:name => categories[2]).first
    if candidate
      names = candidate.ancestor_chain.collect(&:name)
      if names == [categories[0], categories[1], categories[2]]
        return candidate
      else
        return false # There was a candidate, but the ancestors don't match up
      end
    else
      return false # There wasn't even a candidate
    end
  end

  def self.validate_arguments(categories)
    unless categories.count == 3 and categories.is_a?(Array)
      raise ArgumentError "CategoryDispatcher only works with 3 levels of categories. #{categories.count} where given instead."
    end
  end
end
