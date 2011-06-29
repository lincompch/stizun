class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :product
  
  validates_presence_of :product_id
  validates :email, :presence => true, :email => true
  before_create :generate_remove_hash
  
  def generate_remove_hash
    self.remove_hash = Digest::MD5.hexdigest("#{Time.now}==#{self.email}==#{self.product_id}")
  end
  
  
  # User could be a actual user or email address
  def self.get_remove_hash(user, product)
    user = user.is_a?(User) ? user.email : user
    # There is no possibility that more than 1 notification exist for the same product and email
    where(:product == product && :email == user ).first.remove_hash
  end
  
  def set_active
    self.active = true
    self.save
  end
  
  def deactivate
    self.active = false
    self.save
  end
  
  def self.deliver_emails
     where(:active => true).group_by{ |m| m.email }.each do |email, notifications|
       StoreMailer.product_notification(email, notifications).deliver
       notifications.each {|notification| notification.deactivate }
     end
  end
end
