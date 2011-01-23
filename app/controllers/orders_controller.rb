class OrdersController < ApplicationController
  
  def new
    @cart = load_cart

    if @cart.cart_lines.count == 0
      flash[:error] = I18n.t("stizun.order.shopping_cart_empty")
      redirect_to cart_path
    else
      @order = load_order
      @order.shipping_address = Address.new
      @order.billing_address = Address.new
    end
  end
  
  def index
    # Safety measure so that orders are only shown if there is a user id set.
    # Might want to redirect with an error flash instead.
    @orders = []
    
    if params[:user_id]
      if current_user == User.find(params[:user_id])
        @orders = Order.where(:user_id => params[:user_id]).order('status_constant ASC, created_at DESC')
      end
    end
  end
  
  
  def create
    @order = Order.new(params[:order])

    # TODO: Ugly as sin. Improve.
    billing_address = get_address(params[:billing_address_id], params[:billing_address])
    @order.billing_address = billing_address
    shipping_address = get_address(params[:shipping_address_id], params[:shipping_address])
    @order.shipping_address = shipping_address
    
    if current_user
      unless params[:save_shipping_address].blank?
        current_user.addresses << shipping_address
      end

      unless params[:save_billing_address].blank?
        current_user.addresses << billing_address
      end
      current_user.orders << @order
      current_user.save
    end
    
    # Copy lines from the cart to the order
    @cart = load_cart
    @order.order_lines_from_cart(@cart)
    
    
    
    if @order.save
      @cart.destroy
      
      if @order.direct_shipping? == true
        invoice_order(@order)
      end
      
      @order.send_order_confirmation(current_user)
        
      flash[:notice] = I18n.t("stizun.order.thanks_for_your_order")
      
      # Redirect to a summary page instead
      redirect_to products_path
    else
      flash[:error] = I18n.t("stizun.order.problem_with_your_order")
      render :action => 'new'
    end
  end
  

  
  private
  
  def load_order
    @order ||= Order.new
    return @order
  end
  
  def invoice_order(order)
    invoice = Invoice.new_from_order(@order)      
    if invoice.save
      @order.update_attributes(:status_constant => Order::AWAITING_PAYMENT)
    else
      History.add("Could not create invoice for order #{@order.document_id} during checkout, must manually invoice this.", History::ACCOUNTING, @order)
    end
  end
  
  # Picks either an ID-based address (existing in the database) or returns
  # a fresh address created from the parameters given by e.g. a form input
  def get_address(id, params)
    if id.blank? or id.nil?
      address = Address.new(params)
    else
      address = Address.find(id)
    end
    return address
  end
  
  # TODO: Refactor this into a separate method shared with the CartsController
  def load_cart
    Cart.get_from_session(session)
  end
  
  
end
