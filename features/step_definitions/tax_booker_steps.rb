Given /^there is a configuration item named "([^\"]*)" with value "([^\"]*)"$/ do |name, value|
  ConfigurationItem.create(:name => name, :value => value)
end

When /^I invoice the order$/ do
  @invoice = Invoice.create_from_order(@order)
end

When /^the invoice is paid$/ do
  accts_receivable = Account.find_by_name("Accounts Receivable")
  ci = ConfigurationItem.create(:key => "accounts_receivable_id",
                                :value => accts_receivable.id)
  @invoice.record_payment_transaction
end

Then /^the invoice total is (\d+\.\d+)$/ do  |num|
# Debug
#    puts "total price is #{@invoice.rounded_price}"
#    puts @invoice.inspect
#    @invoice.lines.each do |line|
#      puts "rounded [#{line.quantity}]x #{line.text} [#{line.single_rounded_price}] = [#{line.rounded_price}], tax #{line.taxes}"
#      puts "gross line [#{line.gross_price}]"
#      #puts line.inspect.to_s
#    end
  @invoice.price.should == BigDecimal.new(num.to_f.to_s)
end

Then /^the balance of the sales income account is (\d+\.\d+)$/ do |balance|
  Account.find(ConfigurationItem.get('sales_income_account_id').value).balance.should == BigDecimal.new(balance.to_s)
end
