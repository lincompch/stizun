class Admin::SupplyItemsController < Admin::BaseController

  def index
    
    @supplier = Supplier.find(params[:supplier_id])
    @root_category = @supplier.category
    cache_manufacturers_for_supplier(@supplier)
    
    @search = @supplier.supply_items.metasearch(params[:search])
    @supply_items = @search.paginate :per_page => SupplyItem.per_page, :page => params[:page]
    
  end
  
  def update
    @supply_item = SupplyItem.find(params[:id])
    @updated = @supply_item.update_attributes(params[:supply_item])

    respond_to do |format|
      format.js {render :layout => false}
    end    
  end
  
  
  def cache_manufacturers_for_supplier(supplier)

    @manufacturers_array = Rails.cache.read("supplier_#{supplier}_manufacturers")
    if @manufacturers_array.nil?
      @manufacturers_array = supplier.supply_items.group("manufacturer").collect(&:manufacturer).compact.sort
      Rails.cache.write("supplier_#{supplier}_manufacturers", @manufacturers_array)
    end

  end
  
end
