TaxClass.find_or_create_by(:percentage => "8.0", :name => 'Schweizer Mehrwertsteuer (Normalsatz)')
Category.create(:name => 'Main category')
Usergroup.create(:name => 'Admins', :is_admin => true)

# Set your shop's currency here
ConfigurationItem.create(:name => 'Currency', :key => 'currency', :value => 'CHF', :description => 'The currency for your shop.')

# Your shop's postal address separated by \n for newlines
ConfigurationItem.create(:name => 'Address', :key => 'address', :value => 'Something Co.\nSomewhere Way\nSomeplace City\n1234 Somewhere', :description => 'Your shop\'s postal address, separated by \n for newlines.')

# Your company's VAT registration number 
ConfigurationItem.create(:name => 'VAT registration number', :key => 'vat_number', :value => '123 456', :description => 'Your shop\'s VAT registration number.')

PaymentMethod.create(:name => 'Vorkasse', :default => true)
PaymentMethod.create(:name => 'Rechnung/Bankzahlung')

Country.create(:name => 'Schweiz/Suisse/Svizzera/Svizra')
