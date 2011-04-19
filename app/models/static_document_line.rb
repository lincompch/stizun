class StaticDocumentLine < ActiveRecord::Base
  
  validates_inclusion_of :quantity, :in => 1..1000, :message => "must be between 1 and 1000" 

  def recalculate_totals
    self.gross_price = self.quantity * self.single_untaxed_price
    self.taxes = (self.gross_price / 100.0) * self.tax_percentage
    self.taxed_price = (self.gross_price + self.taxes).rounded
    self.single_price = self.single_untaxed_price + ((self.single_untaxed_price / 100.0) * self.tax_percentage)
  end
  
end
