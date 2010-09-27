class Admin::HistoriesController <  Admin::BaseController
  helper LaterDude::CalendarHelper
  
  def index
    # @month and @year are used for calendar flipping only, not
    # to specify the target date whose histories to display.
    #
    # You should use params[:date] to specify the date to scope for.
 
    # params[:year] and params[:month] are used for pagination
    params[:year] ? @year = params[:year].to_i : @year = Date.today.year
    params[:month] ? @month = params[:month].to_i : @month = Date.today.month
    
    # Which date to scope for?
    params[:date] ? @target_date = Date.parse(params[:date]) : @target_date = Date.today
   
    
    if params[:filters]
      @filters = []
      params[:filters].each do |f| 
        @filters << f.to_i unless @filters.include?(f.to_i)
      end
      session[:history_filters] = @filters
    elsif session[:history_filters]
      @filters = session[:history_filters]
    else
      # Use all filters that are available
      @filters = History.type_array
      session[:history_filters] = @filters
    end
  
    if @target_date
      conditions = nil
      
      if @filters
        conditions = {:type_const => @filters}
      end
      
      @histories = History.for_day(@target_date)\
                          .find(:all, :conditions => conditions, :order => "created_at DESC")\
                          .paginate(:page => params[:page], :per_page => 100)
    else
      @histories = [] 
    end
  end

end