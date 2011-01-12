class Admin::ProductsController <  Admin::BaseController
  
  def index
   
     # Resource was accessed in nested form through /admin/categories/n/products
    if params[:category_id]
      @category = Category.find params[:category_id]
      # Which categories to display on top of the product list for deeper
      # navigation into the category tree.
      @categories = @category.children
      search_object = @category.products
    end
  
    # Search inside a category if it is defined, otherwise all products.
    search_object ||= Product
    @categories ||= Category.roots
    
    if params[:search].blank? or params[:search][:keyword].blank?

      @products = search_object.all.paginate(:page => params[:page], :per_page => Product.per_page)
    else
      @products = search_object.search(params[:search][:keyword],
                                       :max_matches => 10000,
                                       :per_page => Product.per_page,
                                       :page => params[:page])
    end
  end
  
  def create
    @product = Product.create(params[:product])
    if @product.save
      flash[:notice] = "Product created."
      redirect_to edit_admin_product_path(@product)
    else
      flash[:error] = "Error creating product."
      render :action => 'new', :layout => 'admin_blank'
    end
  end
  
  def new
    @product = Product.new
    # Must add this, otherwise the product picture partial in 
    # views/admin/products/new.html.erb fails
    #@product.product_pictures << ProductPicture.new
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
  
  
  def new_from_supply_item
    @supply_item = SupplyItem.find(params[:supply_item_id])
    @product = Product.new_from_supply_item(@supply_item)
    render :action => 'new', :layout => 'admin_blank'
  end
  

  
end
