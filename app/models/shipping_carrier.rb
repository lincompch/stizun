class ShippingCarrier < ActiveRecord::Base
  has_one :order


end