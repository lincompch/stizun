class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]
  
  def show
    @user = @current_user
    @invoices = @user.invoices.unpaid
    @orders_to_ship = @user.orders.to_ship
    @orders_awaiting_payment = @user.orders.awaiting_payment
    @orders_processing = @user.orders.processing
    @orders_unprocessed = @user.orders.unprocessed
    @addresses = @user.addresses.active
  end
  def me
    show
    render :action => 'show'
  end
end
