class AddConfigurationItemForTaxBookerName < ActiveRecord::Migration
  def self.up
    ConfigurationItem.create(:key => 'tax_booker_class_name',
                             :value => 'TaxBookers::DummyTaxBooker',
                             :name => 'Tax Booker class name',
                             :description => 'The class name of the tax booker class that should be used to handle taxes on sales.')
  end

  def self.down
    ci = ConfigurationItem.find_by_key('tax_booker_class_name')
    if ci
      ci.destroy
    end
  end
end
