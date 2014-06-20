class Admin::UsersController < Admin::BaseController

  def index
    if params[:search]
      @email = params[:search][:email] || ""
      @firstname = params[:search][:firstname] || ""
      @lastname = params[:search][:lastname] || ""
      @company = params[:search][:company] || ""
      @users = User.all
      @users = @users.where("users.email LIKE ?", "%#{@email}%") unless @email.blank?
      @users = @users.where("addresses.firstname LIKE ?", "%#{@firstname}%").joins(:addresses).uniq unless @firstname.blank?
      @users = @users.where("addresses.lastname LIKE ?", "%#{@lastname}%").joins(:addresses).uniq unless @lastname.blank?
      @users = @users.where("addresses.company LIKE ?", "%#{@company}%").joins(:addresses).uniq unless @company.blank?
      @users = @users.paginate(:page => params[:page], :per_page => 50)
    else
      @users = User.paginate(:page => params[:page], :per_page => 50)
    end
  end

  def edit
    @user = User.find(params[:id])
    @addresses = @user.addresses.order("status")
    render :layout => 'admin_blank'
  end

  def update
    @user = User.find(params[:id])
    @user.update_attributes(params.permit![:user])
    if @user.save
      flash[:notice] = "User updated."
    else
      flash[:error] = "Error updating user."
    end
    redirect_to :back
    #render :action => 'admin/edit', :layout => 'admin_blank'
  end

end

