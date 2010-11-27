class PaymentMethod < ActiveRecord::Base
  
  has_many :invoices
  has_many :orders
  has_and_belongs_to_many :users
  
  
  def self.get_default
    # If no default is in the database, create a conservative one 
    # automatically so we can at least guarantee that one exists at any time.
    return self.first(:conditions => { :default => true }) || \
           self.create(:name => 'Auto-created default', 
                       :default => true, 
                       :allows_direct_shipping => false)
  end
  
  def allows_direct_shipping?
    allows_direct_shipping
  end
  
end
