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


Country.create(:name => 'Schweiz/Suisse/Svizzera/Svizra')

# Lots of accounting stuff
assets = Account.create(:name => 'Assets', :type_constant => Account::ASSETS)
liabilities = Account.create(:name => 'Liabilities', :type_constant => Account::LIABILITIES)
income = Account.create(:name => 'Income', :type_constant => Account::INCOME)
expense = Account.create(:name => 'Expense', :type_constant => Account::EXPENSE)
receivable = Account.create(:name => 'Accounts Receivable')
assets.children << receivable
assets.save


bank = Account.find_by_name("Bank")
unless bank
  bank = Account.create(:name => 'Bank', :parent => assets)
end

ConfigurationItem.create(:key => 'bank_account_id', :value => bank.id, :name => "Bank Account ID", :description => "The bank account that invoice payments are booked to by default, e.g. Bank/Invoices.")


receivable = Account.find_by_name('Accounts Receivable')
ConfigurationItem.create(:name => 'Accounts Receivable ID',
                          :key => 'accounts_receivable_id',
                          :value => receivable.id,
                          :description => "The ID of the account under which additional accounts receivable are created when the system needs to automatically create them. This is extremely important, e.g. during the order process.")

sia = Account.find_by_name("Sales Income")
unless sia
  sia = Account.create(:name => 'Sales Income')
  sia.parent = Account.find_by_name("Income")
  sia.save
end

ci = ConfigurationItem.new(:key => 'sales_income_account_id', :value => sia.id, :name => "Sales Income Account ID", :description => "The income account where sold items are booked to by default.")
ci.save
  


ConfigurationItem.create(:key => 'tax_booker_class_name',
                          :value => 'TaxBookers::DummyTaxBooker',
                          :name => 'Tax Booker class name',
                          :description => 'The class name of the tax booker class that should be used to handle taxes on sales.')

