Given /^I have ordered some stuff$/ do
  create_product({'name' => 'Fish', 'category' => 'Animals', 'supplier' => 'Alltron AG', 'purchase_price' => 100.0})
  create_product({'name' => 'Terminator T-1000', 'category' => 'Cyborgs', 'supplier' => 'Alltron AG', 'purchase_price' => 100.0})
  And %{I view the category "Animals"}
  And %{I add the product called "Fish" to my cart 3 times}
  And %{I view the category "Cyborgs"}
  And %{I add the product called "Terminator T-1000" to my cart 2 times}
end

Given /^the sales income account is configured$/ do
  ConfigurationItem.create(:name => "sales_income_account_id", :key => "sales_income_account_id", :value => Account.find_by_name("Product Sales"))
end

Given /^the accounts receivable account is configured$/ do
  ConfigurationItem.create(:name => "accounts_receivable_id", :key => "accounts_receivable_id", :value => Account.find_by_name("Accounts Receivable"))
end


When /^I add the product "([^\"]*)" to my cart (\d+) times$/ do |name, num|
  # TODO: Optimize and clean up this horrible mess
  all("table.productlist tr").each do |tr|
    unless tr.text.match(name).nil?
      tr.all("input").each do |input|
        field_id = input['id'] if (!input['id'].nil? and !input['id'].match("^quantity").nil?)
        if field_id
          box_id = tr.find(".compact_add_to_cart_box")['id']
          fill_in field_id, :with => num
          within "##{box_id}" do
            click_button 'Kaufen'
          end
        end
      end
    end
  end

end


When /^I visit the checkout$/ do
  visit cart_path
  click_link "Weiter zur Kasse"
end

When /^I submit my order$/ do
  click_button "Bestellung aufgeben"
end

Then /^I should see an order summary$/ do
  # TODO: Right now we check for the German (Switzerland) text because that's the
  # default locale. In future, the default locale should be en_UK and we should check
  # both for that and for the German one, plus whether switching between the two works.
  page.should have_content("Zusammenfassung Ihrer Bestellung")
end

Then /^my cart should contain a product named "([^\"]*)"$/ do |arg1|
  visit cart_path
  page.should have_content(arg1)
end

Then /^my cart should contain a product named "([^\"]*)" (\d+) times$/ do |name, quantity|
  visit cart_path
  #page.should have_selector("input", :name => 'cart_line[quantity]', :value => arg2)
  #page.should have_content(arg1)
  all("#cart_table tr").each do |line|
    if line.text =~ /#{name}/
      line.find("td.qty input").value.to_i.should == quantity.to_i
    end
  end

end

Then /^my cart should contain some stuff$/ do
      Then %{my cart should contain a product named "Fish" 3 times}
      And %{my cart should contain a product named "Terminator T-1000" 2 times}
end

Then /^I should receive (\d+) e\-mails$/ do |num|
  @emails = ActionMailer::Base.deliveries
  @emails.count.should == num.to_i
end

Then /^the subject of e\-mail (\d+) should be "([^"]*)"$/ do |num, subject|
  # Adjust for human-readable numbers instead of index
  # positions used in the .feature text
  index = num.to_i - 1
  @emails[index].subject.should == subject
end


Then /^the order summary should contain a total excluding VAT of (\d+)\.(\d+)$/ do |arg1, arg2|
  amount = (arg1.to_s + "." + arg2.to_s).to_f

  pending # express the regexp above with the code you wish you had
end

Then /^the order summary should contain a VAT of (\d+)\.(\d+)$/ do |arg1, arg2|
  amount = (arg1.to_s + "." + arg2.to_s).to_f
  pending # express the regexp above with the code you wish you had
end

Then /^the order summary should contain a product total including VAT of (\d+)\.(\d+)$/ do |arg1, arg2|
  amount = (arg1.to_s + "." + arg2.to_s).to_f
  pending # express the regexp above with the code you wish you had
end

Then /^the order summary should contain VAT on shipping of (\d+)\.(\d+)$/ do |arg1, arg2|
  amount = (arg1.to_s + "." + arg2.to_s).to_f
  pending # express the regexp above with the code you wish you had
end

Then /^the order summary should contain a grand total of (\d+)\.(\d+)$/ do |arg1, arg2|
  amount = (arg1.to_s + "." + arg2.to_s).to_f
  pending # express the regexp above with the code you wish you had
end
