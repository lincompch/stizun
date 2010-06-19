class Admin::SupplyItemsController < Admin::BaseController

  def index
    #@products = Product.find(:all)
    #@products = Product.paginate(:page => params[:page], :per_page => Product.per_page)
    @supplier = Supplier.find(params[:supplier_id])
    
    if params[:search].blank? or params[:search][:keyword].blank?
      @supply_items = @supplier.supply_items.search.all.paginate(:page => params[:page], :per_page => SupplyItem.per_page)
    else
      
      @supply_items = @supplier.supply_items.name_like_or_supplier_product_code_is_or_manufacturer_product_code_is(params[:search][:keyword]).paginate(:page => params[:page], :per_page => SupplyItem.per_page)
    end
  end
    
end
