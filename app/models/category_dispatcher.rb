class CategoryDispatcher < ActiveRecord::Base

  validates_presence_of :level_01, :level_02,:level_03
  has_and_belongs_to_many :categories


  def self.dispatch(category_array, options = {})
    self.validate_arguments(category_array)
    # Find out if there is a configuration for this set of categories
    configuration = self.where(:level_01 => category_array[0],
                               :level_02 => category_array[1],
                               :level_03 => category_array[2]).first
    if configuration.nil? or configuration.categories.empty?
      return false
    else
      return configuration.categories
    end
  end

  def self.validate_arguments(category_array)
    unless category_array.is_a?(Array) and category_array.count == 3
      raise ArgumentError "CategoryDispatcher only works with 3 levels of category_array. #{category_array.count} where given instead."
    end
  end
end
