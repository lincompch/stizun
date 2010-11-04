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
  has_and_belongs_to_many :usergroups

  def self.find_by_login_or_email(login)
    User.find_by_login(login) || User.find_by_email(login)
  end

  def is_admin?
    usergroups.collect(&:is_admin).include?(true)
  end
  
  # At the moment we only deal with one account per
  # user. Multi-account support may be added in the future.
  def get_account
    if self.accounts.blank?
      account = Account.new
      account.user = self
      account.name = self.email
      account.parent = Account.find_by_id(ConfigurationItem.get("accounts_receivable_id").value)
      self.accounts << account
      account.save
    else
      account = self.accounts.first
    end
    return account
  end
  
  # BUG: Below breaks user.save if the user hasn't existed before, it leads to
  # a bizarre "primary key not unique" error even on empty tables
  # Make sure any new user has an account
#   def before_create
#     get_account
#   end

end
