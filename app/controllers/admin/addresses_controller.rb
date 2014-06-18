class Admin::AddressesController < Admin::BaseController

  def edit
    @address = Address.find(params[:id])
    render :layout => 'admin_blank'
  end

  def update
    @address = Address.find(params[:id])
    @address.update_attributes(params.permit![:address])
    if @address.save
      flash[:notice] = "Address saved."
    else
      flash[:error] = "Address could not be saved"
    end
    render :controller => 'admin/users', :action => 'edit', :id => @address.user, :layout => 'admin_blank'
  end
  
end
