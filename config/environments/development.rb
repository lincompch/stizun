silence_warnings do
  begin
    require 'pry'
    IRB = Pry
  rescue LoadError
  end
end


Stizun::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  # config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  config.cache_store = :memory_store

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_deliveries = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true
  config.assets.compile = true

  # Additional assets to precompile that would otherwise be ignored
  #config.assets.precompile += %w( stylesheet.css print.css stylesheets/templates/lincomp/stylesheet.css stylesheets/templates/lincomp/print.css )
  #config.assets.precompile += [ /stylesheet\.css/, /print\.css/ ]

# Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  config.action_mailer.default_url_options = { :host => "localhost:3000" }

  config.log_level = :info
end

