class DocumentLine < ActiveRecord::Base
  belongs_to :product
  
  validates_inclusion_of :quantity, :in => 1..1000, :message => "must be between 1 and 1000" 

  
  def taxed_price
    self.quantity * self.product.taxed_price
  end
  
  def gross_price
    self.quantity * self.product.gross_price
  end
  
  def price
    self.quantity * self.product.price
  end
  
  def taxes
    self.quantity * self.product.taxes
  end
  
end
