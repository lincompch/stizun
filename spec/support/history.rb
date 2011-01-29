def history_should_exist(options = {})
   History.where(:text => options[:text],
                 :type_const => options[:type_const]).first.nil?.should == false

end