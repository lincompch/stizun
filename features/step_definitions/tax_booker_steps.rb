Given /^there is a configuration item named "([^\"]*)" with value "([^\"]*)"$/ do |name, value|
  ConfigurationItem.create(:name => name, :value => value)
end
