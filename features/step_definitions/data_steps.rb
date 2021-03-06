Given /^a country called "([^"]*)" exists$/ do |name|
  @country = Country.find_or_create_by(:name => name)
end

Given /^there is a configuration item named "([^\"]*)" with value "([^\"]*)"$/ do |name, value|
  ci = ConfigurationItem.find_by_key(name)
  if ci
    ci.value = value
    ci.save
  else
    ci = ConfigurationItem.new(:description => name,:name => name, :key => name, :value => value)
    ci.save
  end
end

Given /^ActionMailer is set to test mode$/ do
  ActionMailer::Base.delivery_method = :test
  ActionMailer::Base.perform_deliveries = true
  # clear all the email deliveries, so we can easily check the new ones
  ActionMailer::Base.deliveries.clear
end
