class Admin::AddressesController < Admin::BaseController

  def edit
    @address = Address.find(params[:id])
    render :layout => 'admin_blank'
  end

end
