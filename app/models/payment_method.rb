class PaymentMethod < ActiveRecord::Base
  
  has_many :invoices
  has_many :orders
  has_and_belongs_to_many :users
  
  
  # Returns the first default shipping fee that's configured for the system.
  # If no default fee exists, a very conservative one is created and returned.
  def self.get_default
    # If no default is in the database, create a conservative one 
    # automatically so we can at least guarantee that one exists at any time.
    return self.first(:conditions => { :default => true }) || \
           self.create(:name => 'Auto-created default', 
                       :default => true)
  end
  
end
