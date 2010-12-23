

When /^I invoice the order$/ do
  # TODO: This depends on these accounts actually being there. Create the accounts
  # if they aren't. Find them, if they need to be found.
  ConfigurationItem.create(:name => "accounts_receivable_id", :key => "accounts_receivable_id", :value => Account.find_by_name("Accounts Receivable"))
  
  ConfigurationItem.create(:name => "sales_income_account_id", :key => "sales_income_account_id", :value => Account.find_by_name("Product Sales"))
  
  @invoice = Invoice.create_from_order(@order)
end

When /^the invoice is paid$/ do
  # TODO: These accounts should all exist and be configured in the system anyway.
  # Should make sure that they exist in the core of the system instead of here.
  accts_receivable = Account.find_by_name("Accounts Receivable")
  ci = ConfigurationItem.create(:key => "accounts_receivable_id",
                                :value => accts_receivable.id)
  
  bank_account = Account.find_by_name("Bank")
  ci = ConfigurationItem.find_or_create_by_key(:key => "bank_account_id", 
                                :value => bank_account.id)
  
  @invoice.record_payment_transaction
end

Then /^the invoice total is (\d+\.\d+)$/ do  |num|      
   @invoice.taxed_price.should == BigDecimal.new(num.to_s)
end

Then /^the balance of the sales income account is (\d+\.\d+)$/ do |balance|
  Account.find(ConfigurationItem.get('sales_income_account_id').value).balance.should == BigDecimal.new(balance.to_s)
end
