class JournalEntry < ActiveRecord::Base

  def self.add(credit_account_name, debit_account_name, text, amount)
    self.create(:credit_account_name => credit_account_name,
                :debit_account_name => debit_account_name,
                :text => text,
                :amount => amount)
  end
  
  
end