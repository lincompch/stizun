class ConfigurationItem < ActiveRecord::Base

  
  validates_uniqueness_of :key
  
  # Get the configuration item as stored in the database under that key.
  def self.get(key)
    self.find_by_key(key)
  end
  
  # Set the value of a certain key.
  def self.set(key, value)
    item = self.get(key)
    if item.nil?
      # Maybe raise exception so that we know this key doesn't exist
      return false
    else
      item.value = value
      item.save
      return item
    end
  end
  
  def to_s
    return "Name: #{name}. K: #{key}, V: #{value}"
  end
  
  
end
