class Numerator < ActiveRecord::Base
  
  def self.get_number
    numerator = self.first
    numerator.count += 1
    numerator.save
    
    return numerator.count
  end

end
