class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = t("stizun.users.account_created_successfully")
      redirect_to :controller => 'users', :action => 'me'
    else
      flash[:error] = t("stizun.users.account_not_created")
      render :action => :new
    end
  end
  
  def show
    @user = @current_user
    @invoices = @user.invoices.unpaid
    @orders_to_ship = @user.orders.to_ship
    @orders_awaiting_payment = @user.orders.awaiting_payment
    @orders_processing = @user.orders.processing
    @addresses = @user.addresses.active
  end

  def me
    show
    render :action => 'show'
  end
  
  def edit
    @user = @current_user
  end
  
  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to user_path(@user)
    else
      render :action => :edit
    end
  end
end
