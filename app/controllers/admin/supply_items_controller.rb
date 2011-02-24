class Admin::SupplyItemsController < Admin::BaseController

  def index
    
   
    
    #@products = Product.find(:all)
    #@products = Product.paginate(:page => params[:page], :per_page => Product.per_page)
    @supplier = Supplier.find(params[:supplier_id])

      @category01_array = Rails.cache.read("supplier_#{@supplier}_category01")
      if @category01_array.nil?
        @category01_array = @supplier.supply_items.group("category01").collect(&:category01)
        @category01_array.sort! unless @category01_array.nil?
        Rails.cache.write("supplier_#{@supplier}_category01", @category01_array)
      end
         
      @category02_array = Rails.cache.read("supplier_#{@supplier}_category02")
      if @category02_array.nil?
        @category02_array = @supplier.supply_items.group("category02").collect(&:category02)
        @category02_array.sort! unless @category02_array.nil?
        Rails.cache.write("supplier_#{@supplier}_category02", @category01_array)
      end
      
      @category03_array = Rails.cache.read("supplier_#{@supplier}_category03")
      if @category03_array.nil?
        @category03_array = @supplier.supply_items.group("category03").collect(&:category03)
        @category03_array.sort! unless @category03_array.nil?
        Rails.cache.write("supplier_#{@supplier}_category03", @category01_array)
      end
      
    
      keyword = nil
      keyword = params[:search][:keyword] unless params[:search].blank? or params[:search][:keyword].blank?
      conditions = {}
      conditions[:category01] = params[:category01] unless params[:category01].blank?
      conditions[:category02] = params[:category02] unless params[:category02].blank?
      conditions[:category03] = params[:category03] unless params[:category03].blank?
      
      @supply_items = @supplier.supply_items.search(keyword,
                                                    :conditions => conditions,
                                                    :per_page => SupplyItem.per_page,
                                                    :page => params[:page],
                                                    :max_matches => 10000)
  end
    
end
