When /^there are the following margin ranges:$/ do |table|	
 table.hashes.each do |mr|
	 # Since we only get strings from the hashes method
	 if mr['start_price'] == "nil" and mr['end_price'] == "nil"
		 start_price = nil
	   end_price = nil
	 else
		 start_price = mr['start_price'].to_f
		 end_price = mr['end_price'].to_f
	 end
   range = FactoryGirl.build(:margin_range)
	 range.start_price = start_price
	 range.end_price = end_price
	 range.margin_percentage = mr['margin_percentage'].to_f
	 range.save.should == true
 end
end
