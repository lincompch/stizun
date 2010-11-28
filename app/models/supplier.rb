class Supplier < ActiveRecord::Base

  # === Associations
  belongs_to :shipping_rate
  belongs_to :address
  has_many :categories
  has_many :products
  has_many :supply_items

  # === Validations
  validates_presence_of :supply_rate_id
  
end
