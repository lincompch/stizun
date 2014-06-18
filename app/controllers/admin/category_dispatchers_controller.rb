class Admin::CategoryDispatchersController < Admin::BaseController

  def index
    @supplier = Supplier.find(params[:supplier_id])

    @level_01 = ""
    @level_02 = ""
    @level_03 = ""

    pagination_options = {:page => params[:page], :per_page => 30}
    if params[:filter]

      @level_01 = params[:filter][:level_01] or ""
      @level_02 = params[:filter][:level_02] or ""
      @level_03 = params[:filter][:level_03] or ""

      if params[:filter][:without_categories].to_i == 1
        @dispatchers = @supplier.category_dispatchers.without_categories
      elsif params[:filter][:with_categories].to_i == 1
        @dispatchers = @supplier.category_dispatchers.with_categories
      else
        @dispatchers = @supplier.category_dispatchers
      end

      #binding.pry
      @dispatchers = @dispatchers.where("level_01 LIKE ? AND level_02 LIKE ? AND level_03 LIKE ?", "%#{@level_01}%","%#{@level_02}%", "%#{@level_03}%").paginate(pagination_options)

    else
      @dispatchers = @supplier.category_dispatchers.paginate(pagination_options)
    end
  end

  def update
    filter = params[:filter] || nil
    @category_dispatcher = CategoryDispatcher.find(params[:id])
    if @category_dispatcher.update_attributes(params.permit![:category_dispatcher])
      redirect_to :action => :index, :filter => filter
      flash[:notice] = "Dispatcher '#{@category_dispatcher.to_s}' updated"
    else
      redirect_to :action => :index, :filter => filter
      flash[:error] = "An error occurred while setting the target category for dispatcher '#{@category_dispatcher}'"
    end
   
  end

  def destroy
    @category_dispatcher = CategoryDispatcher.find(params[:id])
    if @category_dispatcher.destroy
      flash[:notice] = "Dispatcher destroyed."
    else
      flash[:error] = "Dispatcher could not be destroyed."
    end
    filter = params[:filter] if params[:filter]
    redirect_to :action => :index, :filter => filter
  end


end
