class History < ActiveRecord::Base
  
  def self.per_page
    return 100
  end
  
  def self.add(text, object)
    self.create(:text => text, :object_type => object.class.to_s, :object_id => object.id)
  end
  
  def self.add_text(text)
    self.create(:text => text, :object_type => nil, :object_id => nil)
  end
  
  
  def self.for_day(date, order = "created_at DESC" )
    self.find(:all, :conditions => { :created_at => date.midnight..date.midnight + 1.day },  :order => order)
  end
 
  
end
