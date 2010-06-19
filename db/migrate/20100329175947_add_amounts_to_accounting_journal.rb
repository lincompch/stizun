class AddAmountsToAccountingJournal < ActiveRecord::Migration
  def self.up
    add_column :journal_entries, :amount, :decimal
  end

  def self.down
    remove_column :journal_entries, :amount
  end
end
