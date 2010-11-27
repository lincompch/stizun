Given /^a country called "([^"]*)" exists$/ do |name|
  @country = Country.find_or_create_by_name(name)
end
