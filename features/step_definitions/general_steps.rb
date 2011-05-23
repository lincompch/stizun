When "I start the debugger" do
  debugger; puts "lalala!"
end


When /^I wait for (\d+) seconds$/ do |num|
  sleep(num.to_f)
end