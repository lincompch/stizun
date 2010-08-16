class TaxBookers::DummyTaxBooker < TaxBookers::TaxBooker
# This class just writes gross prices and taxes to STDOUT

  def self.record_customer_payment_for(document)
    #puts "DummyTaxBooker: document.gross_price = #{document.gross_price}"
    puts "DummyTaxBooker: document.taxes = #{document.taxes}"
  end

end