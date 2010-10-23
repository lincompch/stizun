class OrderLine < DocumentLine
  belongs_to :order
  # belongs_to :product  # This is already set on DocumentLine level

end