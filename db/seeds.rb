# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)


TaxClass.find_or_create_by_percentage_and_name(:percentage => 8.0, :name => 'Schweizer Mehrwertsteuer (Normalsatz)')
Category.create(:name => 'Main category')
Usergroup.create(:name => 'Admins', :is_admin => true)

# Set your shop's currency here
ConfigurationItem.create(:name => 'Currency', :key => 'currency', :value => 'CHF', :description => 'The currency for your shop.')

# Your shop's postal address separated by \n for newlines
ConfigurationItem.create(:name => 'Address', :key => 'address', :value => 'Something Co.\nSomewhere Way\nSomeplace City\n1234 Somewhere', :description => 'Your shop\'s postal address, separated by \n for newlines.')

# Your company's VAT registration number 
ConfigurationItem.create(:name => 'VAT registration number', :key => 'vat_number', :value => '123 456', :description => 'Your shop\'s VAT registration number.')




# No longer necessary, automatically overrides from custom/store_mailer
#ConfigurationItem.create(:name => 'E-Mail Template Directory', :key => 'email_template_directory', :value => 'lincomp', :description => 'The subdirectory of views/store_mailer/templates that the text for order cofirmation and invoice e-mails is taken from.')


PaymentMethod.create(:name => 'Vorkasse', :default => true)
PaymentMethod.create(:name => 'Rechnung/Bankzahlung')

Country.create(:name => 'Schweiz/Suisse/Svizzera/Svizra')


sr = ShippingRate.new(:name => 'Swiss Post', :default => true)  
sr.tax_class = TaxClass.find_or_create_by_percentage("8.0")
# Source: http://www.post.ch/post-startseite/post-privatkunden/post-versenden/post-pakete-inland/post-pakete-inland-preise.htm

sr.shipping_costs << ShippingCost.new(:weight_min => 0, :weight_max => 2000, :price => 8.0)
sr.shipping_costs << ShippingCost.new(:weight_min => 2001, :weight_max => 5000, :price => 10.0)
sr.shipping_costs << ShippingCost.new(:weight_min => 5001, :weight_max => 10000, :price => 13.0)
sr.shipping_costs << ShippingCost.new(:weight_min => 10001, :weight_max => 20000, :price => 19.0)
sr.shipping_costs << ShippingCost.new(:weight_min => 20001, :weight_max => 30000, :price => 26.0)

# This default tax class for shipping would need to be made configurable in the 
# final system, especially if it is going to be released as Free Software.
sr.shipping_costs.each do |sc|
  sc.tax_class = TaxClass.find_or_create_by_percentage("8.0")
end
sr.save