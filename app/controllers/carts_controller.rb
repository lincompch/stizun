class CartsController < ApplicationController

  def add_product
    @cart = load_cart
    product = Product.find(params[:product_id])
    @cart.add_product(product, params[:quantity])
    if @cart.save
      flash[:notice] = "Product added."
      redirect_to products_path
    else
      flash[:error] = "Product could not be added."
      redirect_to products_path
    end
  end
  
  def remove_one
    @cart = load_cart
    product = Product.find(params[:product_id])
    # TODO: Remove one product quantity with this ID
    # Can do this via change_quantity
  end
  
  def remove_all
    @cart = load_cart
    product = Product.find(params[:product_id])
    if @cart.remove_all(product)
      flash[:notice] = "Product removed"
    else
      flash[:notice] = "Product wasn't removed. Perhaps it wasn't in this cart?"
    end
    redirect_to products_path
  end
  
  def checkout
    @cart = load_cart
  end
  
  def change_quantity
    @cart = load_cart
    product = Product.find(params[:product_id].to_i)
    quantity = params[:quantity].to_i
    @cart.change_quantity(product, quantity)
    redirect_to products_path
  end
  
  def update
    @cart = load_cart
    submitted_cart = params[:cart]
     submitted_cart[:cart_lines].each do |cl|
       line_id = cl[0].to_i # id
       quantity = cl[1]['quantity'].to_i # desired quantity of this id
       CartLine.find(line_id).change_quantity(quantity)
     end
    flash[:notice] = "Cart updated."
    redirect_to products_path
  end
  
  def empty
    @cart = load_cart      
  end
  
  def show
    # This is reused as the checkout view
    @cart = load_cart
  end
  
  # TODO: Refactor this into a separate method shared with the CartsController
  def load_cart
    if session[:cart_id] and Cart.exists?(session[:cart_id])
      cart = Cart.find(session[:cart_id])
    else
      cart = Cart.new
      cart.save
      session[:cart_id] = cart.id
    end
    return cart
  end
  
  
end
