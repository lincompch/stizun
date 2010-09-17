Given /^the following accounts exist:$/ do |table|

  table.hashes.each do |a|
    
    if a['type'] != "inherited" and a['parent'] == "none"
      Account.create(:name => a['name'],
                     :type_constant => a['type'].constantize
                    )
    else
      parent = Account.find_by_name(a['parent'])
      acc = Account.create(:name => a['name'])
      acc.parent = parent
      acc.save
    end
    
  end

  ConfigurationItem.create(:name => "accounts_receivable_id", :key => "accounts_receivable_id", :value => Account.find_by_name("Accounts receivable"))
  
  ConfigurationItem.create(:name => "sales_income_account_id", :key => "sales_income_account_id", :value => Account.find_by_name("Product Sales"))

   
end


When /^the amount (\d+\.\d+) is credited to "([^\"]*)" and debited to "([^\"]*)"$/ do |amount, credit, debit|
  credit_account = Account.find_by_name(credit)
  debit_account = Account.find_by_name(debit)
  AccountTransaction.transfer(credit_account, debit_account, amount, "Testing account system")
end

Then /^the balance of account "([^\"]*)" is (\d+\.\d+)$/ do |account, balance|
  Account.find_by_name(account).balance.should == BigDecimal.new(balance.to_s)
end

Then /^the account "([^\"]*)" should be of type "([^\"]*)"$/ do |account, type|
  Account.find_by_name(account).type_constant.should == type.constantize 
end





# These might be general-purpose, might make sense to refactor to a general
# step definition file

Then /^an exception of type "([^\"]*)" is raised$/ do |arg1|
  # How do I test for the last action's result to see if it's an exception?
  pending # express the regexp above with the code you wish you had
end
