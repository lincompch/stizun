class Supplier < ActiveRecord::Base

  # === Associations
  belongs_to :address
  has_one :category # should be has_one :category
  has_many :products
  has_many :supply_items
  
end
