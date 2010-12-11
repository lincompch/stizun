class UserSession < Authlogic::Session::Base
  
  validate do |user_session|
    #user_session.errors.add_to_base(I18n.t("stizun.user_sessions.email_cant_be_blank")) if user_session.email.blank?
    #user_session.errors.add_to_base(I18n.t("stizun.user_sessions.password_cant_be_blank")) if user_session.password.blank?

  end
  
  find_by_login_method :find_by_login_or_email
  
end