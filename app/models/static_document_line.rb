class StaticDocumentLine < ActiveRecord::Base
  
  validates_inclusion_of :quantity, :in => 1..1000, :message => "must be between 1 and 1000" 

  before_save :recalculate_totals
  
  def recalculate_totals
    single_untaxed_price_after_rebate = self.single_untaxed_price - self.single_rebate
    self.gross_price = self.quantity * single_untaxed_price_after_rebate
    self.taxes = (self.gross_price / BigDecimal.new("100.0")) * self.tax_percentage
    self.taxed_price = (self.gross_price + self.taxes).rounded
    self.single_price = single_untaxed_price_after_rebate + ((single_untaxed_price_after_rebate / BigDecimal.new("100.0")) * self.tax_percentage)
    self.single_price = self.single_price.rounded
  end

  def has_rebate?
    !single_rebate.blank? and single_rebate > BigDecimal.new("0.0")
  end
  
end
