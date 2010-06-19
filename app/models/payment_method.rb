class PaymentMethod < ActiveRecord::Base
  
  has_many :invoices
  has_many :orders
  has_and_belongs_to_many :users
  
  
  def self.get_default
    return self.first(:conditions => { :default => true })
  end
  
end
