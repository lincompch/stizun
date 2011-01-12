class Admin::SupplyItemsController < Admin::BaseController

  def index
    #@products = Product.find(:all)
    #@products = Product.paginate(:page => params[:page], :per_page => Product.per_page)
    @supplier = Supplier.find(params[:supplier_id])
    
    if params[:search].blank? or params[:search][:keyword].blank?
      @supply_items = @supplier.supply_items.all.paginate(:page => params[:page], :per_page => SupplyItem.per_page)
    else
      
      @supply_items = @supplier.supply_items.search(params[:search][:keyword], 
                                                    :per_page => SupplyItem.per_page,
                                                    :max_matches => 10000)\
                                                    .paginate(:page => params[:page], 
                                                              :per_page => SupplyItem.per_page)
    end
  end
    
end
