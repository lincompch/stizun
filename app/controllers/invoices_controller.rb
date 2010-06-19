class InvoicesController < ApplicationController
  
  def uuid
    @invoice = Invoice.find_by_uuid(params[:uuid])
     if @invoice.nil?
       flash[:error] = "This invoice does not exist."
       redirect_to root_path
     end
  end
  
  def index
    
    @invoices =[]
    if params[:user_id]
      if current_user == User.find(params[:user_id])
        @invoices = Invoice.find(:all, :conditions => { :user_id => params[:user_id] }, :order => 'status_constant ASC, created_at DESC'  )
      end
    end
  
  end
  
end
