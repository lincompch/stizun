require 'tax_bookers/dummy_tax_booker'

class TaxBookers::TaxBooker
  delegate_class = ConfigurationItem.get('tax_booker_class_name').value
  @tax_booker = delegate_class.constantize
  
  def self.record_customer_payment_for(document)
    @tax_booker.record_customer_payment_for(document)
  end
 

end