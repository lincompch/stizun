class Admin::SupplyItemsController < Admin::BaseController

  def index
    @supplier = Supplier.find(params[:supplier_id])
    cache_manufacturers_for_supplier(@supplier)
    cache_category_tree_for_supplier(@supplier) # Previous implementation needed this
    keyword = nil
    keyword = params[:search][:keyword] unless params[:search].blank? or params[:search][:keyword].blank?
    conditions = {}
    conditions[:manufacturer] = params[:manufacturer] unless params[:manufacturer].blank?
    conditions[:category_string] = Riddle.escape(params[:category_string]) unless params[:category_string].blank?

    order = :name
    sort_mode = :asc
    
    order = params[:order].to_sym unless params[:order].blank?
    
    @supply_items = @supplier.supply_items.sphinx_available_items.search(keyword,
                                                  :conditions => conditions,
                                                  :per_page => SupplyItem.per_page,
                                                  :page => params[:page],
                                                  :max_matches => 100000,
                                                  :order => order,
                                                  :sort_mode => sort_mode,
                                                  :include => :product) # eager loading speeds up this view from e.g. 2500 ms to 1900 ms
  end

  def update
    @supply_item = SupplyItem.find(params[:id])
    @updated = @supply_item.update_attributes(params[:supply_item])

    respond_to do |format|
      format.html do
        if @updated == true
          flash[:notice] = "Supply item saved"
          render :action => 'edit'
        else
          flash[:error] = "Couldn't save supply item."
          render :action => 'edit'
        end
      end
      format.js {render :layout => false}
    end
  end

  def new
    @supply_item = SupplyItem.new
    @supplier = Supplier.find(params[:supplier_id])
  end

  def create
    @supply_item = SupplyItem.new(params[:supply_item])
    @supplier = Supplier.find(params[:supplier_id])
    @supply_item.supplier = @supplier
    if @supply_item.save
      flash[:notice] = "Supply Item created"
      redirect_to :action => 'edit', :supplier => @supplier, :id => @supply_item
    else
      flash[:error] = "Couldn't create supply item"
      render :action => 'new'
    end
  end

  def edit
    @supply_item = SupplyItem.find(params[:id])
    @supplier = @supply_item.supplier
  end


  def cache_manufacturers_for_supplier(supplier)
    @manufacturers_array = Rails.cache.read("supplier_#{supplier}_manufacturers")
    if @manufacturers_array.nil?
      @manufacturers_array = supplier.supply_items.group("manufacturer").collect(&:manufacturer).compact.sort
      Rails.cache.write("supplier_#{supplier}_manufacturers", @manufacturers_array)
    end
  end

  def cache_category_tree_for_supplier(supplier)
    @category_tree = Rails.cache.read("supplier_#{supplier.id}_category_tree")
    if @category_tree.nil?
      @category_tree = SupplyItem.category_tree(supplier)
      Rails.cache.write("supplier_#{supplier.id}_category_tree", @category_tree)
    end
  end



end
