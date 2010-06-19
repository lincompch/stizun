class CartLine < DocumentLine
  belongs_to :cart
  # belongs_to :product  # This is already set on DocumentLine level
  
  def change_quantity(quantity)
    result = false
    if quantity <= 0
      result = true if self.destroy
    else
      self.quantity = quantity
      result = true if self.save
    end
    return result
  end
  
end