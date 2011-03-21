class Admin::ComponentsController <  Admin::BaseController
  
  def index
    @product = Product.find(params[:product_id])
    @product_sets = @product.product_sets
    render :layout => 'admin_blank'
  end

  def new
    @product = Product.find(params[:product_id])
    @component = Product.new
    render :layout => 'admin_blank'

  end
  
  def create
    quantity = params[:quantity].to_i
    product_id = params[:product_id].to_i
    component = SupplyItem.find(params[:component_id].to_i)
    @product = Product.find(params[:product_id])

    if @product.add_component(component, quantity)
      @product.touch
      @product.save
      flash[:notice] = "Component added."
    else
      flash[:error] = "Component could not be added."
    end
    render :action => 'new', :layout => 'admin_blank'

  end
  
  def destroy
#     @product = Product.find(params[:product_id])
#     quantity = params[:quantity].to_i
#     component = SupplyItem.find(params[:component_id].to_i)
#     
#     if @product.remove_component(component, quantity)
#       flash[:notice] = "Component removed"
#     else
#       flash[:error] = "Component could not be removed"
#     end
    @product_set = ProductSet.find(params[:id])
    product = @product_set.product
    
    if @product_set.destroy
      product.touch
      product.save
      flash[:notice] = "Component removed"
    else
      flash[:error] = "Component could not be removed"
    end
    redirect_to :controller => 'admin/components', :action => 'index', :product_id => product.id
  end
  
end