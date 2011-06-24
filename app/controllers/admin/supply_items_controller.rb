class Admin::SupplyItemsController < Admin::BaseController

  def index
    @supplier = Supplier.find(params[:supplier_id])
    @root_category = @supplier.category
    cache_manufacturers_for_supplier(@supplier)
    @search = @supplier.supply_items.metasearch(params[:search])
    if params[:category_id] and !params[:category_id].blank?
      category = Category.find(params[:category_id])
      result = @search.where(:category_id => category.children_categories.collect(&:id))
    else
      result = @search
    end
    @supply_items = result.paginate :per_page => SupplyItem.per_page, :page => params[:page]
  end
    
  def cache_manufacturers_for_supplier(supplier)
    @manufacturers_array = Rails.cache.read("supplier_#{supplier}_manufacturers")
    if @manufacturers_array.nil?
      @manufacturers_array = supplier.supply_items.group("manufacturer").collect(&:manufacturer).compact.sort
      Rails.cache.write("supplier_#{supplier}_manufacturers", @manufacturers_array)
    end
  end
  
end
