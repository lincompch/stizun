class TaxBookers::SwitzerlandTaxBooker
  @logger = RAILS_DEFAULT_LOGGER
  
  
  def self.record_customer_payment_for(document)
    self.pre_flight_check
    
    @logger.info "SwitzerlandTaxBooker: document.gross_price = #{document.gross_price}, Vorsteuer account = #{@vorsteuer}"
    @logger.info "SwitzerlandTaxBooker: document.taxes = #{document.taxes}, MwSt. account = #{@mehrwertsteuer}"
  end

  
  private
  
  def self.pre_flight_check
    unless @vorsteuer = Account.find_by_name("Debitor Vorsteuer")
      @vorsteuer = Account.create(:name => "Debitor Vorsteuer",
                                  :parent => Account.find_by_name("Assets"))
    end
    
    unless @mehrwertsteuer = Account.find_by_name("Kreditor MwSt.")
      @mehrwertsteuer = Account.create(:name => "Kreditor MwSt.",
                                  :parent => Account.find_by_name("Liabilities"))
    end
    
  end
  
end