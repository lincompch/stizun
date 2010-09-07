class TaxBookers::SwitzerlandTaxBooker
  @logger = RAILS_DEFAULT_LOGGER
  
  
  def self.record_customer_payment_for(document)
    self.pre_flight_check
    
    #AccountTransaction.transfer(document.taxes
    
    @logger.info "SwitzerlandTaxBooker: document.gross_price = #{document.gross_price}, Vorsteuer account = #{@vorsteuer}"
    @logger.info "SwitzerlandTaxBooker: document.taxes = #{document.taxes}, MwSt. account = #{@mehrwertsteuer}"
  end

  
  private
  
  def self.pre_flight_check
    
    # TODO: This can be optimized by creating ConfigurationItems relevant
    # only to this TaxBooker, so that each of these accounts is configurable
    
    # These four accounts need to exist to book taxes according to Swiss laws
    # and best practices
    unless @vorsteuer = Account.find_by_name("Debitor Vorsteuer")
      @vorsteuer = Account.create(:name => "Debitor Vorsteuer",
                                  :parent => Account.find_by_name("Assets"))
    end
    
    unless @mehrwertsteuer = Account.find_by_name("Kreditor MwSt.")
      @mehrwertsteuer = Account.create(:name => "Kreditor MwSt.",
                                  :parent => Account.find_by_name("Liabilities"))
    end
    
    unless @warenaufwand = Account.find_by_name("Warenaufwand")
      @warenaufwand = Account.create(:name => "Warenaufwand",
                                  :parent => Account.find_by_name("Expense"))
    end
    
    unless @warenertrag = Account.find_by_name("Warenertrag")
      @warenertrag = Account.create(:name => "Warenertrag",
                                  :parent => Account.find_by_name("Income"))
    end
    
  end
  
end