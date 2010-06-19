class Admin::JournalEntriesController <  Admin::BaseController

  def index
    @journal_entries = JournalEntry.all.paginate(:page => params[:page], :per_page => 100)
  end

end