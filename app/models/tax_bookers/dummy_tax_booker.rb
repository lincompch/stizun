# This class just writes gross prices and taxes to the logger

class TaxBookers::DummyTaxBooker
  @logger = Rails.logger
  
  def self.record_invoice(document)
    @logger.info "DummyTaxBooker: document.gross_price = #{document.gross_price}"
    @logger.info "DummyTaxBooker: document.taxes = #{document.taxes}"
  end

end