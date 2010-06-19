class ProductSet < ActiveRecord::Base
  belongs_to :component, :class_name => "SupplyItem"
  belongs_to :product
  
  validates_inclusion_of :quantity, :in => 1..100, :message => "must be between 1 and 100" 
  
  
  # Alias method for compatibility
  def rounded_price
   purchase_price
  end
  
  def purchase_price
    self.quantity * self.component.purchase_price
  end
   
  def weight
    self.quantity * self.component.weight
  end
  
#   def margin
#     self.quantity * self.component.margin
#   end
  
  
end