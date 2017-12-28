def history_should_exist(options = {})
   expect(History.where(:text => options[:text],
                        :type_const => options[:type_const]).first.nil?).to be false

end
