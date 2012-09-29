class CategoryDispatcher < ActiveRecord::Base

  validates_presence_of :level_01, :level_02,:level_03
  belongs_to :target_category, :class_name => "Category"

  def self.dispatch(categories, options = {})
    self.validate_arguments(categories)
    # Find out if there is a configuration for this set of categories
    configuration = self.where(:level_01 => categories[0],
                               :level_02 => categories[1],
                               :level_03 => categories[2])
    if configuration.nil? or configuration.collect(&:target_category).compact.empty?
      return false
    else
      return configuration.collect(&:target_category)
    end
  end

  def self.validate_arguments(categories)
    unless categories.count == 3 and categories.is_a?(Array)
      raise ArgumentError "CategoryDispatcher only works with 3 levels of categories. #{categories.count} where given instead."
    end
  end
end
