# encoding: utf-8
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
  
  validate :disallow_poboxes

  scope :active, :conditions => {:status => 'active'}
  scope :deleted, :conditions => {:status => 'deleted'}

  
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
  
  def disallow_poboxes
    begin
      disallow = true if ConfigurationItem.get("disallow_pobox_in_addresses").value == "1"
    rescue
      disallow = false
    end

    if disallow == true
      # Simplify the string for easier matching: P.O. Box -> pobox, P.O.Box -> pobox, PO Box -> pobox etc.
      simplified_street = self.street.downcase.gsub(".", "").gsub(" ", "").gsub("î", "i")
      if simplified_street.match("(pobox|casepostale|boitepostale|casellapostale|poinscatoli|postfach)").nil?
        return true
      else
        errors.add("Address","Wir können leider nicht an Postfächer liefern. Bitte geben Sie eine richtige Domiziladresse an.")
        return false
      end
    end
  end


  def self.option_hash_for_select(user)
    unless user.addresses.active.nil? or user.addresses.active.count == 0
      options = [[I18n.t("stizun.address.select_an_address") , nil]]
      options += user.addresses.active.collect {|a| [ a.one_line_summary, a.id ]}
    else
      options = [[I18n.t("stizun.address.you_have_no_saved_addresses") , nil]]
    end
    return options
  end

end
