class Admin::ProductsController <  Admin::BaseController
  
  def index
   
     # Resource was accessed in nested form through /admin/categories/n/products
    if params[:category_id]
      @category = Category.find params[:category_id]
    end
    
    if params[:search].blank? or params[:search][:keyword].blank?
      if @category.nil?
        @products = Product.search.all.paginate(:page => params[:page], :per_page => Product.per_page)
      else
        @products = @category.products.search.all.paginate(:page => params[:page], :per_page => Product.per_page)
      end
    else
      
      if @category.nil?
        @products = Product.name_like_or_supplier_product_code_is_or_manufacturer_product_code_is(params[:search][:keyword]).paginate(:page => params[:page], :per_page => Product.per_page)
      else 
        @products = @category.products.name_like_or_supplier_product_code_is_or_manufacturer_product_code_is(params[:search][:keyword]).paginate(:page => params[:page], :per_page => Product.per_page)
      end
    end
  end
  
  def create
    @product = Product.create(params[:product])
    if @product.save
      flash[:notice] = "Product created."
      redirect_to edit_admin_product_path(@product)
    else
      render :action => 'new', :layout => 'admin_blank'
    end
  end
  
  def new
    @product = Product.new
    render :layout => 'admin_blank'
  end
  
  def edit
    @product = Product.find(params[:id])
    render :layout => 'admin_blank'
  end
  
  def show
    
  end
  
  def update
    @product = Product.find(params[:id])
    @product.update_attributes(params[:product])

    # The "add component" button was pressed -- refactor this into a separate
    # page inside a fancybox and a separate controller method once the component 
    # functionality is more robust
    if params[:add_component]
      component = SupplyItem.find(params[:component_id].to_i)
      @product.add_component(component, params[:quantity].to_i)
    end
    
    if @product.save
      flash[:notice] = "Product updated."
    else
      flash[:error] = "Error updating product."
    end
    render :action => 'edit', :layout => 'admin_blank'
  end
  
  def destroy
    @product = Product.find(params[:id])
    if @product.destroy
      flash[:notice] = "Product destroyed."
    else
      flash[:error] = "Product couldn't be destroyed!"
    end
    
    redirect_to admin_products_path
  end
  
  
  def create_from_supply_item
    @supply_item = SupplyItem.find(params[:supply_item_id])
    @product = Product.new_from_supply_item(@supply_item)
    render :action => 'edit', :layout => 'admin_blank'
  end
  

  
end
