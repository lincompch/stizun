class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.login_field = 'email'
  end

  
  has_many :carts
  has_many :orders
  has_many :addresses
  has_many :accounts
  has_many :invoices
  has_and_belongs_to_many :payment_methods
  
  def self.find_by_login_or_email(login)
    User.find_by_login(login) || User.find_by_email(login)
  end

  
  # At the moment we only deal with one account per
  # user. Multi-account support may be added in the future.
  def get_account
    if self.accounts.blank?
      account = Account.new
      account.user = self
      account.name = self.email
                                         # set in environment.rb
      account.parent = Account.find_by_id(ACCOUNTS_RECEIVABLE_ID)
      self.accounts << account
      account.save
    else
      account = self.accounts.first
    end
    return account
  end
  
  # Make sure any new user has an account
  def before_create
    self.get_account
  end

end
