#encoding: utf-8
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :set_locale, :setup_piwik
  #helper_method :current_user_session, :current_user

  def require_user
    unless current_user
      flash[:error] = "Sie müssen eingeloggt sein, um auf diese Seite zuzugreifen."
      redirect_to new_user_session_path
      return false
    end
  end

  def require_no_user
    if current_user
      flash[:error] = I18n.t("stizun.account.only_for_not_logged_in")
      redirect_to root_path
      return false
    end
  end

  def after_sign_in_path_for(resource)
    if resource.is_a?(User)
      # Don't want to break the user's order flow by redirecting them to their account page, so
      # let's continue in the order process instead.
      if params[:original_referrer] =~ /orders\/new$/
        params[:original_referrer]
      else
        url_for :controller => "/users", :action => :show
      end
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    # Doesn't make sense to redirect to a page that requires login!
    if resource_or_scope == :user and !request.referrer.match(/users/).nil?
      root_path
    else
      request.referrer
    end
  end

  def set_locale
    # if params[:locale] is nil then I18n.default_locale will be used
    #I18n.locale = params[:locale]
    # Currently hard-coded during development
    I18n.locale = :"de-CH"
  end

  def setup_piwik
    @piwik_address = nil
    @piwik_cookie_domain = nil

    begin
      @piwik_address = ConfigurationItem.get("piwik_address").value
      @piwik_cookie_domain = ConfigurationItem.get("piwik_cookie_domain").value
    rescue
    end
  end

end
