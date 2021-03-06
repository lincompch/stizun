class DocumentLine < ActiveRecord::Base
  belongs_to :product
  
  validates_inclusion_of :quantity, :in => 1..1000, :message => "must be between 1 and 1000" 

  
  def taxed_price
    (self.quantity * self.product.taxed_price).rounded
  end
  
  def gross_price
    self.quantity * self.product.gross_price
  end
  
  def price
    (self.quantity * self.product.price).rounded
  end
  
  def taxes
    # Bottom-up calculation from single taxes
    self.quantity * self.product.taxes
    # Top-down calculation from gross price
    #(self.gross_price / BigDecimal.new("100.0")) * self.product.tax_class.percentage
  end
  
end
