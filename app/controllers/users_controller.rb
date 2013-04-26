class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]
  
  def show
    @user = @current_user
    @invoices = @user.invoices.unpaid.order("created_at DESC")
    @orders_to_ship = @user.orders.to_ship.order("created_at DESC")
    @orders_awaiting_payment = @user.orders.awaiting_payment.order("created_at DESC")
    @orders_processing = @user.orders.processing.order("created_at DESC")
    @orders_unprocessed = @user.orders.unprocessed.order("created_at DESC")
    @last_shipped_orders = @user.orders.shipped.order("created_at DESC").limit(5)
    @addresses = @user.addresses.active
    @notifications = @user.notifications

    # To return after switching off notifications for a product
    session[:return_to] = user_path(@user)
  end
  
  def me
    show
    render :action => 'show'
  end
end
