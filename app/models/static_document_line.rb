class StaticDocumentLine < ActiveRecord::Base
  
  validates_inclusion_of :quantity, :in => 1..1000, :message => "must be between 1 and 1000" 

  before_save :recalculate_totals
  
  def recalculate_totals
    # Line's total prices (qty * amount)
    single_untaxed_price_after_rebate = BigDecimal.new( (self.single_untaxed_price - self.single_rebate).to_s )
    self.gross_price = BigDecimal.new( (self.quantity * single_untaxed_price_after_rebate).to_s )
    self.gross_price = self.gross_price
    self.taxes = (self.gross_price / BigDecimal.new("100.0")) * self.tax_percentage
    self.taxed_price = (BigDecimal.new( (self.gross_price + self.taxes).to_s )).rounded # Rounded like in document_line.rb

    # Line's single prices (for qty 1 * amount)
    single_taxes = ((single_untaxed_price_after_rebate / BigDecimal.new("100.0")) * self.tax_percentage) # like in product.rb
    self.single_price = single_untaxed_price_after_rebate + single_taxes

#    binding.pry
  end

  def has_rebate?
    !single_rebate.blank? and single_rebate > BigDecimal.new("0.0")
  end
  
end
