class Account < ActiveRecord::Base
  
  ASSETS = 1
  LIABILITIES = 2
  INCOME = 3
  EXPENSE = 4
  
  TYPE_HASH = { ASSETS       => 'Assets',
                  LIABILITIES  => 'Liabilities',
                  INCOME       => 'Income',
                  EXPENSE      => 'Expense'}
  
  
  belongs_to :user
  
  acts_as_tree :order => 'name'

  # Look out: Don't call .account_transactions directly on an account.
  # ActiveRecord polymorphism seems broken in this situation, it only
  # returns transactions of the last type defined (e.g. credit_accounts)
  has_many :account_transactions, :as => :debit_account
  has_many :account_transactions, :as => :credit_account


  # Returns an account whose name is linked to an address
  def self.get_anonymous_account(address)
    account = self.find_or_create_by_name(address.one_line_summary)
                                        # set in Configuration Items
    account.parent = Account.find_by_id(ConfigurationItem.get("accounts_receivable_id").value)
    account.save
    return account
  end

  def self.options_for_select
    options = []
    TYPE_HASH.each do |type|
      options << ["---- #{type[1]} ---------", '']
      accounts = Account.find(:all, :conditions => { :type_constant => type[0] }, :order => 'name')
      accounts.each do |acc|
        options << [acc.name, acc.id]
      end
    end
    return options
  end
  
  # Makes sure any children have the same type as their
  # parent.
  def before_save
    if parent and !parent.type_constant.nil?
      self.type_constant = parent.type_constant
    end
  end
  
  def credits
    return AccountTransaction.find(:all, :conditions => {:credit_account_id => self.id})
  end
  
  def debits
    return AccountTransaction.find(:all, :conditions => {:debit_account_id => self.id})
  end
  
  def credit
    sum = 0
    self.credits.each do |c|
      sum += c.amount
    end
    return sum
  end
  
  def debit
    sum = 0
    self.debits.each do |d|
      sum += d.amount
    end
    return sum
  end
  
  # Call this instead of account_transactions directly.
  def transactions
    transactions = []
    ats = AccountTransaction.find(:all, :conditions => ["debit_account_id = ? or credit_account_id = ?", self.id, self.id], :order => 'created_at')
    ats.each do |at|
      type = "credit" if self.id == at.credit_account_id
      type = "debit" if self.id == at.debit_account_id
      transactions << [at.created_at, at.amount, type, at.note]
    end
    return transactions
  end
  
  def balance
    if [Account::ASSETS, Account::EXPENSE].include?(self.type_constant)
      # Balances on the credit side of these accounts are total positive
      return self.credit - self.debit 
    else
      # Balances on the debit side of these accounts are total positive
      return self.debit - self.credit
    end
  end
  

  
end