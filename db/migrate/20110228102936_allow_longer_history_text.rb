class AllowLongerHistoryText < ActiveRecord::Migration
  def self.up
    if ['MySQL', 'Mysql2'].include?(ActiveRecord::Base.connection.adapter_name.to_s)
      execute "ALTER TABLE histories CHANGE text text text"
    else
      execute "ALTER TABLE histories ALTER text SET DATA TYPE text"
    end
  end

  def self.down
    if ['MySQL', 'Mysql2'].include?(ActiveRecord::Base.connection.adapter_name.to_s)
      execute "ALTER TABLE histories CHANGE text text string"
    else
      execute "ALTER TABLE histories ALTER text SET DATA TYPE string"
    end
  end
end
