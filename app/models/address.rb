class Address < ActiveRecord::Base
  has_many :orders, :as => :shipping_address
  has_many :orders, :as => :billing_address
  
  has_many :invoices, :as => :shipping_address
  has_many :invoices, :as => :billing_address
  
  belongs_to :country
  belongs_to :user
  has_many :suppliers
  
  validates_presence_of :country
  validates_presence_of :firstname, :lastname, :city, :postalcode, :email
  
  named_scope :active, :conditions => {:status => 'active'}
  named_scope :deleted, :conditions => {:status => 'deleted'}

  
  def one_line_summary
    return "#{company} #{firstname} #{lastname}, #{street}, #{postalcode} #{city}, #{country.name}" 
  end
  
  def block_summary
    block = "#{company}\n"
    block += "#{firstname} #{lastname}\n"
    block += "#{email}\n"
    block += "#{street}\n"
    block += "#{postalcode} #{city}\n"
    block += "#{country.name}"
    return block
  end
  
  def filled_in?
    filled_in = false
    unless (firstname.blank? \
           and lastname.blank? and email.blank? and postalcode.blank? \
           and city.blank?)
      filled_in = true
    end  
    return filled_in
  end
  
  def self.option_hash_for_select(user)
    unless user.addresses.active.nil? or user.addresses.active.count == 0
      options = [["Please select an address" , nil]]
      options += user.addresses.active.collect {|a| [ a.one_line_summary, a.id ]}
    else
      options = [["Please enter a new address below:" , nil]]
    end
    return options
  end
  
end
