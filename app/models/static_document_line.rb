class StaticDocumentLine < ActiveRecord::Base
  
  validates_inclusion_of :quantity, :in => 1..1000, :message => "must be between 1 and 1000" 
  
end
