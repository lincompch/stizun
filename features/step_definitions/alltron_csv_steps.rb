When /^I import the file "([^"]*)"$/ do |filename|
  require 'lib/alltron_util'
  AlltronUtil.import_supply_items(Rails.root + filename)
end

When /^I destroy all supply items$/ do
  SupplyItem.destroy_all
end

Then /^there are (\d+) supply items in the database$/ do |num|
  SupplyItem.all.count.should == num.to_i
end
