class Admin::BaseController < ApplicationController
  layout 'admin'
  
  before_filter :admins_only
  
  def admins_only
    if current_user.nil? or !current_user.is_admin?
      # Silently redirect, no need to tell anyone why. If they're
      # not an admin, they have no business here
      redirect_to root_path
    end
  end
end
