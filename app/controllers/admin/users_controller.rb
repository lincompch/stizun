class Admin::UsersController < Admin::BaseController
  
  def index
    @users = User.all.paginate(:page => params[:page], :per_page => 50)
  end
  
  def edit
    @user = User.find(params[:id])
    @addresses = @user.addresses.order("status")
    render :layout => 'admin_blank'
  end
  
  def update
    @user = User.find(params[:id])
    @user.update_attributes(params[:user])
    if @user.save
      flash[:notice] = "User updated."
    else
      flash[:error] = "Error updating user."
    end
    redirect_to :back
    #render :action => 'admin/edit', :layout => 'admin_blank'
  end
  
end
