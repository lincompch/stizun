class AllowLongerHistoryText < ActiveRecord::Migration
  def self.up
    if ActiveRecord::Base.connection.adapter_name == 'MySQL'
      execute "ALTER TABLE histories CHANGE text text text"
    else
      execute "ALTER TABLE histories ALTER text SET DATA TYPE text"
    end
  end

  def self.down
    if ActiveRecord::Base.connection.adapter_name == 'MySQL'
      execute "ALTER TABLE histories CHANGE text text string"
    else
      execute "ALTER TABLE histories ALTER text SET DATA TYPE string"
    end
  end
end
