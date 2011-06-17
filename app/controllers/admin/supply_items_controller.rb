class Admin::SupplyItemsController < Admin::BaseController

  def index
    
    @supplier = Supplier.find(params[:supplier_id])
    @root_category = @supplier.category
    cache_manufacturers_for_supplier(@supplier)
    
    keyword = nil
    keyword = params[:search][:keyword] unless params[:search].blank? or params[:search][:keyword].blank?
    conditions = {}
#    conditions[:category01] = params[:category01] unless params[:category01].blank?
#    conditions[:category02] = params[:category02] unless params[:category02].blank?
#    conditions[:category03] = params[:category03] unless params[:category03].blank?
    conditions[:manufacturer] = params[:manufacturer] unless params[:manufacturer].blank?
    conditions[:category_id] = params[:category_id] unless params[:category_id].blank?
    
    @supply_items = @supplier.supply_items.sphinx_available_items.search(keyword,
                                                  :conditions => conditions,
                                                  :per_page => SupplyItem.per_page,
                                                  :page => params[:page],
                                                  :max_matches => 100000)
  end
    
  def cache_manufacturers_for_supplier(supplier)

    @manufacturers_array = Rails.cache.read("supplier_#{supplier}_manufacturers")
    if @manufacturers_array.nil?
      @manufacturers_array = supplier.supply_items.group("manufacturer").collect(&:manufacturer).compact.sort
      Rails.cache.write("supplier_#{supplier}_manufacturers", @manufacturers_array)
    end

    @category01_array = Rails.cache.read("supplier_#{supplier}_category01")
    if @category01_array.nil?
      @category01_array = supplier.supply_items.group("category01").collect(&:category01).compact.sort
      Rails.cache.write("supplier_#{supplier}_category01", @category01_array)
    end
        
    @category02_array = Rails.cache.read("supplier_#{supplier}_category02")
    if @category02_array.nil?
      @category02_array = supplier.supply_items.group("category02").collect(&:category02).compact.sort
      Rails.cache.write("supplier_#{supplier}_category02", @category03_array)
    end
    
    @category03_array = Rails.cache.read("supplier_#{supplier}_category03")
    if @category03_array.nil?
      @category03_array = supplier.supply_items.group("category03").collect(&:category03).compact.sort
      Rails.cache.write("supplier_#{supplier}_category03", @category03_array)
    end
    
  end
  
end
