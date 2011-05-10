class RemoveAccountingTables < ActiveRecord::Migration
  def self.up
    drop_table :accounts
    drop_table :account_transactions
    drop_table :journal_entries
    
  end

  def self.down
    # This migration is destructive, it can't be reversed
  end
end
