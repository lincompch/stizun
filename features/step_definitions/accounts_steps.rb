Given /^the following accounts exist:$/ do |table|

  table.hashes.each do |a|
    
    # We use name-based stuff a lot in the tests, so we should make
    # sure that account names are unique, at least during testing. In the
    # actual system, it doesn't matter because we refer to accounts only by ID.
    next if not Account.find_by_name(a['name']).nil?
    
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
   
end

When /^the amount (\d+\.\d+) is credited to "([^\"]*)" and debited to "([^\"]*)"$/ do |amount, credit, debit|
  credit_account = Account.find_by_name(credit)
  debit_account = Account.find_by_name(debit)
  AccountTransaction.transfer(credit_account, debit_account, amount, "Testing account system")
end

Then /^the balance of account "([^\"]*)" is (-?\d+\.\d+)$/ do |account, balance|
  Account.find_by_name(account).balance.should == BigDecimal.new(balance.to_s)
end

Then /^the account "([^\"]*)" should be of type "([^\"]*)"$/ do |account, type|
  Account.find_by_name(account).type_constant.should == type.constantize 
end

