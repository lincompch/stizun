class Admin::ProductsController <  Admin::BaseController

  def index

    @manufacturers_array = Rails.cache.read("all_manufacturers")
    if @manufacturers_array.nil?
      @manufacturers_array = Product.group("manufacturer").collect(&:manufacturer).compact.sort
      Rails.cache.write("all_manufacturers", @manufacturers_array)
    end

    conditions = {}

    if !params[:supplier_id].blank?
     conditions.merge!({:supplier_id => params[:supplier_id]})

      @manufacturers_array = Rails.cache.read("supplier_#{params[:supplier_id]}_manufacturers")
      if @manufacturers_array.nil?
        @manufacturers_array = Product.where(:supplier_id => params[:supplier_id]).group("manufacturer").collect(&:manufacturer).compact.sort
        Rails.cache.write("supplier_#{params[:supplier_id]}_manufacturers", @manufacturers_array)
      end
    end


     # Resource was accessed in nested form through /admin/categories/n/products
    if params[:category_id]
      @category = Category.find params[:category_id]
      # Which categories to display on top of the product list for deeper
      # navigation into the category tree.
      @categories = @category.children

    end

      @categories ||= Category.roots

      keyword = nil
      keyword = params[:search][:keyword] unless params[:search].blank? or params[:search][:keyword].blank?
      conditions[:manufacturer] = params[:manufacturer] unless params[:manufacturer].blank?

      with = {}
      with.merge!(:category_id => params[:category_id]) unless params[:category_id].blank?

      keyword = Riddle.escape(keyword) unless keyword.nil?

      @products =       Product.search(keyword,
                                      :conditions => conditions,
                                      :with => with,
                                      :max_matches => 100000,
                                      :per_page => 50,
                                      :page => params[:page])
  end

  def having_unavailable_supply_item
    @manufacturers_array = Rails.cache.read("all_manufacturers")
    if @manufacturers_array.nil?
      @manufacturers_array = Product.group("manufacturer").collect(&:manufacturer).compact.sort
      Rails.cache.write("all_manufacturers", @manufacturers_array)
    end

    @categories = Category.roots
    @products = Product.having_unavailable_supply_item.paginate(:per_page => Product.per_page, :page => params[:page])
    render :action => :index
  end

  def create
    @product = Product.create(product_params)
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
    @product.update_attributes(product_params)

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
    #render :action => 'edit', :layout => 'admin_blank'
    redirect_to :back
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

  def switch_to_supply_item
   @supply_item = SupplyItem.find(params[:supply_item_id])
   @product = Product.find(params[:id])
   @product.supply_item = @supply_item
   @product.sync_from_supply_item
   if @product.save == true
     flash[:notice] = "Product metamorphosis complete."
   else
     flash[:error] = "Sorry, could not metamorphosize product: #{@product.errors.full_messages}"
   end
   #redirect_to edit_admin_product_path(@product)
   redirect_to :back
  end

  def edit_multiple
    product_ids = cookies[:batch].split(":")
    unless product_ids.empty?
      @products = Product.find(product_ids.map{ |p| p.to_i })
    else
      flash[:error] = "No products selected"
      redirect_to [:admin, :products]
    end
  end

  def update_multiple
    @products = Product.find(product_id_params[:product_ids])
    @products.each do |product|
      product.update_attributes!(product_params.reject { |k,v| v.blank? })
    end
    cookies[:batch] = nil
    flash[:notice] = "Updated products!"
    redirect_to [:admin, :products]
  end

  def remove_cookie
    cookies[:batch] = nil
    flash[:notice] = "Edit multiple products - cleared"
    redirect_to [:admin, :products]
  end


  def switch_to_cheaper_supply_item
    @product = Product.find(params[:id])
    @cheaper_supply_items = @product.cheaper_supply_items
  end

  private

  def product_params
    params.require(:product).permit(:manufacturer_product_code, :product_link, :name, :short_description, :description,
                                    :weight, :supplier_id, :supplier_product_code, :purchase_price, 
                                    :tax_class_id, :sales_price, :stock, :is_build_to_order, :is_available, :is_description_protected, 
                                    :is_featured, :is_visible, :manufacturer, :ean_code, :rebate, :rebate_until, :percentage_rebate, 
                                    :absolute_rebate, :is_loss_leader, :is_description_protected, :category_ids => [])

  end

  def product_id_params
    params.permit(:product_ids => [])
  end

end

