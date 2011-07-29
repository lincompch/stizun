class Admin::SupplyItemsController < Admin::BaseController

  def index
    @supplier = Supplier.find(params[:supplier_id])
    @root_category = @supplier.category
    cache_manufacturers_for_supplier(@supplier)
      keyword = nil

    keyword = params[:search][:keyword] unless params[:search].blank? or params[:search][:keyword].blank?
    conditions = {}
    with = {}
    with_all = {}
    conditions[:manufacturer] = params[:manufacturer] unless params[:manufacturer].blank?
    with.merge!(:category_id => params[:category_id]) unless params[:category_id].blank?
    with_all.merge!(:category_ids => [params[:category_id]]) unless params[:category_id].blank?

    @supply_items = @supplier.supply_items.sphinx_available_items.search(keyword,
                                                  :conditions => conditions,
#                                                  :with => with,
                                                  :with_all => with_all,
                                                  :per_page => SupplyItem.per_page,
                                                  :page => params[:page],
                                                  :max_matches => 100000)
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

