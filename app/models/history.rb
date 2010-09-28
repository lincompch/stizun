class History < ActiveRecord::Base
  
  
  # === Named scopes
  
  named_scope :for_day, lambda { |date|
      { :conditions => { 
          :created_at => date.midnight..date.midnight + 1.day 
        }
      }
  }

  # === Constants and associated methods
  
  GENERAL = 1
  ACCOUNTING = 2
  PRODUCT_CHANGE = 3
  SUPPLY_ITEM_CHANGE = 4
  
  TYPE_CONST_HASH = { GENERAL      => 'General',
                ACCOUNTING   => 'Accounting',
                PRODUCT_CHANGE => 'Product change',
                SUPPLY_ITEM_CHANGE => 'Supply item change'}
  
  # Human-readable representation of the status
  def self.type_to_human(type)
    return TYPE_CONST_HASH[type]
  end
  
  def self.type_array
    array = []
    TYPE_CONST_HASH.each do |c|
      array << c[0]
    end
    return array
  end
  
  # === Methods
  
  def self.exist_for_day?(date)
    #self.first :conditions =>
    !self.for_day(date).first.nil?
  end
  
  def self.add(text, type_const = History::GENERAL, object = nil)
    object_id = nil if object == nil
    object_type = nil if object == nil
    self.create(:text => text, :object_type => object_type, :object_id => object_id, :type_const => type_const)
  end
  
  # For backwards compatibility -- self.add was refactored to accept nil objects, therefore
  # a separate add_text method is no longer really necessary. Remove after refactoring everything
  # to use add instead of add_text
  def self.add_text(text, type_const = History::GENERAL)
    self.create(:text => text)
  end
  
  
end
