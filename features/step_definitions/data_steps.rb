Given /^a country called "([^"]*)" exists$/ do |name|
  @country = Country.find_or_create_by_name(name)
end


Given /^ActionMailer is set to test mode$/ do
  ActionMailer::Base.delivery_method = :test
  ActionMailer::Base.perform_deliveries = true
  # clear all the email deliveries, so we can easily check the new ones
  ActionMailer::Base.deliveries.clear
end