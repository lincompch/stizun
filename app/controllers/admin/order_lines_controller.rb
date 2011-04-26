class Admin::OrderLinesController <  Admin::BaseController

  def edit
    @order_line = OrderLine.find(params[:id])
  end

  def update
    @order_line = OrderLine.find(params[:id])
    @order_line.single_untaxed_price = params[:order_line][:single_untaxed_price]
    @order_line.single_rebate = params[:order_line][:single_rebate]
    if @order_line.save
      flash[:notice] = "Changes saved"
    else
      flash[:error] = "The changes could not be saved."
    end
    redirect_to edit_admin_order_order_line_path(@order_line.order, @order_line)
  end
  
  def create

  end
  
  def destroy

  end
  
end