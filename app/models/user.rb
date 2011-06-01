class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.login_field = 'email'
  end

  has_many :carts
  has_many :orders
  has_many :addresses
  has_many :invoices
  has_and_belongs_to_many :payment_methods
  has_and_belongs_to_many :usergroups

  has_many :notifications
  has_many :products, :through => :notifications

  before_create :add_default_payment_method
  
  def self.find_by_login_or_email(login)
    User.find_by_login(login) || User.find_by_email(login)
  end

  def is_admin?
    usergroups.collect(&:is_admin).include?(true)
  end
  
  def add_default_payment_method
    self.payment_methods << PaymentMethod.get_default
  end
  
end
