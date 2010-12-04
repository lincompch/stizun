class TaxBookers::SwitzerlandTaxBooker
  @logger = RAILS_DEFAULT_LOGGER
  
  
  def self.record_invoice(document)
    self.pre_flight_check

    AccountTransaction.transfer(@warenertrag, @mehrwertsteuer, document.taxes, "Taxes owed from creating invoice  #{document.document_id}", self)
    
  end

  
 # private
  
  def self.pre_flight_check
        
    # TODO: This can be optimized by creating ConfigurationItems relevant
    # only to this TaxBooker, so that each of these accounts is configurable
    
    # These four accounts need to exist to book taxes according to Swiss laws
    # and best practices. Although only two are used automatically in the booker.
    
    # Not used automatically -- actual paid tax must be booked by the accountant
    unless @vorsteuer = Account.find_by_name("Debitor Vorsteuer")
      @vorsteuer = Account.create(:name => "Debitor Vorsteuer",
                                  :parent => Account.find_by_name("Assets"))
    end
    
    # Not used automatically -- actual purchase prices must be booked by the accountant by hand.
    unless @warenaufwand = Account.find_by_name("Warenaufwand")
      @warenaufwand = Account.create(:name => "Warenaufwand",
                                     :parent => Account.find_by_name("Expense"))
    end
   
    unless @mehrwertsteuer = Account.find_by_name("Kreditor MwSt.")
      @mehrwertsteuer = Account.create(:name => "Kreditor MwSt.",
                                       :parent => Account.find_by_name("Liabilities"))
    end
    
    # TODO: Move this to the ConfigItem named sales_income_account_id
    unless @warenertrag = Account.find_by_name("Product Sales")
      @warenertrag = Account.create(:name => "Product Sales",
                                    :parent => Account.find_by_name("Income"))
    end
    
  end
  
end