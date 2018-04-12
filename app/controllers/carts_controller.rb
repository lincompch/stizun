class CartsController < ApplicationController

  before_filter :set_up_product_updates


  def set_up_product_updates
    @product_updates = nil
  end
  
  def add_product
    @cart = Cart.get_from_session(session)
    product = Product.find(params[:product_id])
    @cart.add_product(product, params[:quantity])
    if @cart.save
      flash[:notice] = t("stizun.cart.product_added")
    else
      flash[:error] = t("stizun.cart.product_not_added")
    end

    if request.env["HTTP_REFERER"].blank?  
      redirect_to @cart
    else
      redirect_to(:back)
    end
  end
  
  def remove_one
    @cart = Cart.get_from_session(session)
    product = Product.find(params[:product_id])
    # TODO: Remove one product quantity with this ID
    # Can do this via change_quantity
  end
  
  def remove_all
    @cart = Cart.get_from_session(session)
    product = Product.find(params[:product_id])
    if @cart.remove_all(product)
      flash[:notice] = t("stizun.cart.product_removed")
    else
      flash[:notice] = t("stizun.cart.product_not_removed")
    end
      redirect_to(:back)
  end
  
  def checkout
    @cart = Cart.get_from_session(session)
    #live_update_products
  end
  
  def change_quantity
    @cart = Cart.get_from_session(session)
    product = Product.find(params[:product_id].to_i)
    quantity = params[:quantity].to_i
    @cart.change_quantity(product, quantity)
    redirect_to(:back)
  end
  
  def update
    @cart = Cart.get_from_session(session)
    if params[:cart]
      submitted_cart = params[:cart]
      submitted_cart[:cart_lines].each do |cl|
        line_id = cl[0].to_i # id
        quantity = cl[1]['quantity'].to_i # desired quantity of this id
        CartLine.find(line_id).change_quantity(quantity)
      end
      flash[:notice] = t("stizun.cart.cart_updated")
    else
      flash[:notice] = t("stizun.cart.cart_updated")
    end
    redirect_to(:back)

  end
  
  def empty
    @cart = Cart.get_from_session(session)
  end
  
  def show
    # This is reused as the checkout view
    @cart = Cart.get_from_session(session)
    #live_update_products
    @piwik = cart_to_piwik(@cart)
  end
  

  def live_update_products
    @product_updates = @cart.live_update_products
    unless @product_updates.empty?
      @cart.lines.each do |line|
        line.product.reload
      end
    end

  end
  
  def cart_to_piwik(cart)
    require Rails.root + "lib/piwik"
    piwik = ""
    cart.lines.each do |cl|
      categories = ""
      categories = cl.product.categories.collect(&:name) unless cl.product.categories.empty?
      piwik += piwik_ecommerce_item(cl.product.id, cl.product.name, 
                                    categories, cl.product.taxed_price.rounded,
                                    cl.quantity)
    end

    piwik += piwik_track_ecommerce_cart_update(cart.taxed_price.rounded.to_f)

    return piwik
  end
end
