class Admin::OrdersController <  Admin::BaseController
  def index
    @orders = Order.all(:order => "created_at DESC")
  end
  
  def create
    @order = Order.create(params[:order])
    if @order.save
     # redirect_to admin_order_path(@order)
      redirect_to admin_orders_path
    else
      render :action => 'new'
    end
  end
  
  def new
    @order = Order.new
  end
  
  def edit
    @order = Order.find(params[:id])
  end
  
  def show
    @order = Order.find(params[:id])
  end
  
  def update
    @order = Order.find(params[:id])
    @order.update_attributes(params[:order])

    if @order.save
      flash[:notice] = "Order updated."
      redirect_to edit_admin_order_path @order
    else
      flash[:error] = "Error while saving order!"
      redirect_to edit_admin_order_path @order
    end
  end
  
  def destroy
    @order = Order.find(params[:id])
    if @order.destroy
      redirect_to admin_orders_path
    end
  end
  

end
