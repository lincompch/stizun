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