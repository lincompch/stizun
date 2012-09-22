class Supplier < ActiveRecord::Base

  # === Associations
  belongs_to :address
  has_one :category 
  has_many :margin_ranges
  has_many :products
  has_many :supply_items
  has_many :category_dispatchers
end
