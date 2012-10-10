class Admin::CategoryDispatchersController < Admin::BaseController

  def index
    @supplier = Supplier.find(params[:supplier_id])
  end 

  def update
    @category_dispatcher = CategoryDispatcher.find(params[:id])
    if @category_dispatcher.update_attributes(params[:category_dispatcher])
      redirect_to :action => :index
      flash[:notice] = "Dispatcher '#{@category_dispatcher.to_s}' updated"
    else
      redirect_to :action => :index
      flash[:error] = "An error occurred while setting the target category for dispatcher '#{@category_dispatcher}'"
    end
   
  end

end
