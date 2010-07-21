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

end


When /^the amount 100\.00 is transferred from account "([^\"]*)" to account "([^\"]*)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Then /^the balance of account "([^\"]*)" is 100\.00$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

