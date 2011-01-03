
Stizun::Application.configure do

  # Edit at your own peril - it's recommended to regenerate this file
  # in the future when you upgrade to a newer version of Cucumber.

  # IMPORTANT: Setting config.cache_classes to false is known to
  # break Cucumber's use_transactional_fixtures method.
  # For more information see https://rspec.lighthouseapp.com/projects/16211/tickets/165
  config.cache_classes = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.action_controller.consider_all_requests_local = true
  config.action_controller.perform_caching             = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  config.active_support.deprecation = :log
  
  
  # Oddly, Capybara completely ignores default_locale as set in
  # application.rb, so we need to set it again here, and I suppose
  # only deities know why.
  config.i18n.default_locale = :"de-CH"
  config.i18n.locale = :"de-CH"

  config.action_mailer.default_url_options = { :host => "localhost" }
  
end

