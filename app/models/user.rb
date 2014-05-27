class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  # Setup accessible (or protected) attributes for your model
  devise :database_authenticatable, :registerable,   
    :recoverable, :rememberable, :trackable, :validatable, :encryptable

  has_many :carts
  has_many :orders
  has_many :addresses
  has_many :invoices
  has_and_belongs_to_many :payment_methods
  has_and_belongs_to_many :usergroups

  has_many :notifications
  has_many :products, :through => :notifications

  before_create :add_default_payment_method

  def is_admin?
    usergroups.collect(&:is_admin).include?(true)
  end
  
  def add_default_payment_method
    self.payment_methods << PaymentMethod.get_default
  end

  private

  def user_params
    params.required(:person).permit(:email, :password, :password_confirmation, :remember_me)
  end
  
end
