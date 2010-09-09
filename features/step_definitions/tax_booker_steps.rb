Given /^there is a configuration item named "([^\"]*)" with value "([^\"]*)"$/ do |name, value|
  ConfigurationItem.create(:name => name, :value => value)
end

When /^I invoice the order$/ do
  @invoice = Invoice.create_from_order(@order)
end

Then /^the invoice total should be (\d+\.\d+)$/ do  |num|
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