# encoding: utf-8
class NotificationController < ApplicationController
  
  def index
    @notifications = current_user.notifications
    session[:return_to] = notifications_path
  end
  
  def destroy
    @notification = Notification.find_by_remove_hash(params[:remove_hash])
    product = @notification.product
    @notification.destroy
    
    flash[:notice] = "Abonnement für dieses Produkt abbestellt"
    redirect_to session[:return_to] || product_path(product)
  end
  
end
