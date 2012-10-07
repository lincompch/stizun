class Admin::CategoryDispatchersController < Admin::BaseController

  def index
    @supplier = Supplier.find(params[:supplier_id])
  end 

  def update
    @category_dispatcher = CategoryDispatcher.find(params[:id])
    @category_dispatcher.update_attributes(params[:category_dispatcher])
  end
end
