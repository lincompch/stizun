class Admin::HistoriesController <  Admin::BaseController

  def index
    
    if params[:day]
      @histories = History.find(:all, :conditions => ["date(created_at) = ?", Date.parse(params[:day])],  :order => 'created_at DESC').paginate(:page => params[:page], :per_page => History.per_page)

    else
      @histories = History.all(:group => "day(created_at)").paginate(:page => params[:page], :per_page => History.per_page)
      
      
    end
  end

end