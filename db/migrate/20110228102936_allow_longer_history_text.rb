class AllowLongerHistoryText < ActiveRecord::Migration
  def self.up

    execute "ALTER TABLE histories CHANGE text text text"

  end

  def self.down
    execute "ALTER TABLE histories CHANGE text text string"
  end
end
