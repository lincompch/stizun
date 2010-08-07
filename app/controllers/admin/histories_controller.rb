class Admin::HistoriesController <  Admin::BaseController

  def index
    
    if params[:day]
      @histories = History.find(:all, :conditions => { :created_at => Date.parse(params[:day]).midnight..Date.parse(params[:day]).midnight + 1.day },  :order => 'created_at DESC').paginate(:page => params[:page], :per_page => History.per_page)

    else
      @histories = History.all.paginate(:page => params[:page], :per_page => History.per_page)      
    end
  end

end