class Admin::HistoriesController <  Admin::BaseController
  helper LaterDude::CalendarHelper
  
  def index
    # @month and @year are used for calendar flipping only, not
    # to specify the target date whose histories to display.
    #
    # You should use params[:date] to specify the date to scope for.
    
    params[:year] ? @year = params[:year].to_i : @year = Date.today.year
    params[:month] ? @month = params[:month].to_i : @month = Date.today.month
    params[:date] ? @target_date = Date.parse(params[:date]) : @target_date = Date.today
   
    if @target_date
      @histories = History.for_day(@target_date).order("created_at DESC").paginate(
        :page => params[:page], 
        :per_page => History.per_page
      )
      
    else
      @histories = [] 
    end
  end

end