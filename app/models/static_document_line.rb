class StaticDocumentLine < ActiveRecord::Base
  
  validates_inclusion_of :quantity, :in => 1..1000, :message => "must be between 1 and 1000" 

  before_save :recalculate_totals
  
  # All this BigDecimal wrangling is getting on my nerves, maybe we should move to doing all calculations
  # in cents.
  def recalculate_totals
    single_untaxed_price_after_rebate = BigDecimal.new( (self.single_untaxed_price - self.single_rebate).to_s )
    self.gross_price = BigDecimal.new( (self.quantity * single_untaxed_price_after_rebate).to_s )
    self.taxes = (self.gross_price / BigDecimal.new("100.0")) * self.tax_percentage
    self.taxed_price = BigDecimal.new( (self.gross_price + self.taxes).to_s )
    self.single_price = single_untaxed_price_after_rebate + ((single_untaxed_price_after_rebate / BigDecimal.new("100.0")) * self.tax_percentage)
  end

  def has_rebate?
    !single_rebate.blank? and single_rebate > BigDecimal.new("0.0")
  end
  
end
