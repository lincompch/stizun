#class Cart < ActiveRecord::Base

class Cart < Document
  belongs_to :user
  has_many :cart_lines, :dependent => :destroy
  validates_associated :cart_lines

  def add_product(product, quantity = 1)
    incremented = false
    # Product already in this cart, just increment quantity
    self.cart_lines.each do |scl|
      if scl.product == product
        scl.quantity += quantity.to_i
        scl.save
        incremented = true
      end
    end
  
    if self.cart_lines.empty? or !incremented
        cl = CartLine.new
        cl.product = product
        cl.quantity = quantity.to_i
        self.cart_lines << cl
    end
  end
 
  
  def remove_one(product)
    self.cart_lines.each do |cl|
      if cl.product.id == product.id
        cl.quantity -= 1
        self.cart_lines.delete(cl) if cl.quantity == 0
      end
    end
  end
  
  def remove_all(product)
    self.cart_lines.each do |cl|
      if cl.product.id == product.id
        self.cart_lines.delete(cl)
      end
    end
  end
  
  def change_quantity(product, quantity)
    self.cart_lines.each do |cl|
      if cl.product.id == product.id
        if quantity <= 0
          self.remove_all(product)
        else
          cl.quantity = quantity
          cl.save
        end
      end
    end
  end
  
  def lines
    return cart_lines
  end
  
  def self.get_from_session(session)

    if session[:cart_id] and Cart.exists?(session[:cart_id])
      cart = Cart.find(session[:cart_id])
      # TODO: Remove all products from this cart that are no longer available at this time.
    else
      cart = Cart.new
      cart.save
      session[:cart_id] = cart.id
    end
    return cart
  end
  
end
