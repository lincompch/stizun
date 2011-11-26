ActiveRecord::Base.establish_connection(
  :adapter  => "mysql2",
  :socket => "/var/run/mysqld/mysqld.sock",
  :username => "root",
  :password => "",
  :database => "foo"
)





class SupplyItem < ActiveRecord::Base

  scope :distinct_categories, select("DISTINCT(category)").order("category DESC")

  def self.unique_category_strings(supplier_id = nil)
    return self.distinct_categories.where(:supplier_id => supplier_id).collect(&:category)
  end
end

class RealSupplyItem < ActiveRecord::Base
  set_table_name "supply_items"
end

RealSupplyItem.establish_connection(:adapter  => "mysql2",
  :socket => "/var/run/mysqld/mysqld.sock",
  :username => "root",
  :password => "",
  :database => "stizun_dev")

RealSupplyItem.all.each do |rsi|
  SupplyItem.create(:category => "#{rsi.category01} :: #{rsi.category02} :: #{rsi.category03}")
end

words = ["USB", "Kabel", "Maus", "Mäuse", "Fisch", "Hammer", "USV", "Verlängerungen", "Compact Flash", "Warhammer"]


(1..200000).each do 
  string = "#{words[rand(words.size)]} :: #{words[rand(words.size)]} :: #{words[rand(words.size)]}"
  puts "Creating: #{string}"
  SupplyItem.create(:category => string)
end

--- benchmarking

require 'benchmark'

SupplyItem.connection.execute