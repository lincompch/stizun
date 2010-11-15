Then /^the following history entries exist:$/ do |table|
  table.hashes.each do |h|
    hist = History.find(:all, :conditions => 
                        ["text LIKE ? and type_const = ?", 
                         "%#{h['text']}%",
                         h['type_const'].constantize
                        ])
    hist.count.should > 0
  end
end
