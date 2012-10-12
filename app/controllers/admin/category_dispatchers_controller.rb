class Admin::CategoryDispatchersController < Admin::BaseController

  def index
    @supplier = Supplier.find(params[:supplier_id])
    if params[:filter]
      if params[:filter][:without_categories].to_i == 1
        @dispatchers = @supplier.category_dispatchers.without_categories.paginate(:page => params[:page], :per_page => 30)
      elsif params[:filter][:with_categories].to_i == 1
        @dispatchers = @supplier.category_dispatchers.with_categories.paginate(:page => params[:page], :per_page => 30)
      end
    else
      @dispatchers = @supplier.category_dispatchers.paginate(:page => params[:page], :per_page => 30)
    end

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
