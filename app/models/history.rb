class History < ActiveRecord::Base
  
  named_scope :for_day, lambda { |date|
      { :conditions => { 
          :created_at => date.midnight..date.midnight + 1.day 
        }
      }
  }
  
  def self.exist_for_day?(date)
    #self.first :conditions =>
    !self.for_day(date).first.nil?
  end
  
  def self.per_page
    return 100
  end
  
  def self.add(text, object = nil)
    object_id = nil if object == nil
    object_type = nil if object == nil
    self.create(:text => text, :object_type => object_type, :object_id => object_id)
  end
  
  # For backwards compatibility -- self.add was refactored to accept nil objects, therefore
  # a separate add_text method is no longer really necessary. Remove after refactoring everything
  # to use add instead of add_text
  def self.add_text(text)
    self.create(:text => text)
  end
  
end
