class Supplier < ActiveRecord::Base
  belongs_to :shipping_rate
  belongs_to :address
  has_many :products
  has_many :supply_items

end
