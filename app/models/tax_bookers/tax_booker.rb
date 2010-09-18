require 'tax_bookers/dummy_tax_booker'
require 'tax_bookers/switzerland_tax_booker'

class TaxBookers::TaxBooker
 
  
  def self.record_invoice(document)
    if ConfigurationItem.get('tax_booker_class_name').blank?
      delegate_class = "TaxBookers::DummyTaxBooker"
    else
      delegate_class = ConfigurationItem.get('tax_booker_class_name').value
    end      
    delegate_class.constantize.record_invoice(document)
  end

end