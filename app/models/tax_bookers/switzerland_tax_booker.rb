class TaxBookers::SwitzerlandTaxBooker
  @logger = Rails.logger
  
  
  def self.record_invoice(document)
    self.pre_flight_check

    mehrwertsteuer = Account.find_by_name("Kreditor MwSt.")
    warenertrag = Account.find(ConfigurationItem.get('sales_income_account_id').value)
    AccountTransaction.transfer(warenertrag, mehrwertsteuer, document.taxes, "Taxes owed from creating invoice  #{document.document_id}", document)
    
  end

  
 # private
  
  def self.pre_flight_check
  
    Account.find_or_create_by_name(:name => "Kreditor MwSt.",
                                   :parent => Account.find_by_name("Liabilities"))
    if Account.find(ConfigurationItem.get('sales_income_account_id').value).nil?
      raise ArgumentError("Cannot book Swiss taxes like this. Sales income account is missing.")
    end
    
  end
  
end