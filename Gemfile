source 'http://rubygems.org'

gem 'rails', '3.1.1'

# Allows UJS with jQuery
gem 'jquery-rails'

# Offers Rails 2 f.error_messages etc. helpers on forms
gem 'dynamic_form'

gem 'haml'

# Hacked to work with Rails 3 thanks to rails3-generators
# But need to consider Devise instead

gem 'devise', '<2.0.0' 
gem 'rails3-generators'
gem 'rack-ssl-enforcer'

# CKEditor has a nice Rails integration thanks to Igor Galeta
# Bundler is still hopelessly broken with the :git option ("is not checked out.
# Please run `bundle install`" bug described here: http://www.ruby-forum.com/topic/213962
#gem 'ckeditor', :git => 'git://github.com/galetahub/rails-ckeditor.git', :branch => 'rails3'

# So we use the non-git edition here:
gem 'ckeditor', '3.6.2'

# We better sanitize that HTML!
gem 'sanitize'

gem 'thinking-sphinx'
gem 'carrierwave'
gem 'mini_magick'
gem 'paperclip', ">= 3.0.2"
gem 'mysql2'
gem 'erubis'
gem 'will_paginate', "3.0.0"
gem 'uuidtools'
gem 'later_dude', '>= 0.3.1'
gem "feedzirra", "~> 0.0.24"
gem "ruby-progressbar", :require => "progressbar"
gem 'nokogiri'

gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'daemons'

group :assets do
  gem 'sass-rails', " ~> 3.1.0"
  gem 'coffee-rails', " ~> 3.1.0"
  gem 'uglifier'
end

group :test, :development do
  gem 'simplecov'
  #gem 'factory_girl_rails'
  gem 'fabrication'
  gem 'capybara', ' ~> 1.1'
  gem 'pickle'
  gem 'database_cleaner'
  gem 'cucumber'
  gem 'rspec-rails'
  gem 'spork'
  gem 'launchy'
  gem 'ruby-debug19'
  gem 'ZenTest'
  gem 'pry'
  # gem 'pry-doc'
  gem 'therubyracer', '>= 0.8.2'
end

group :test do 
  gem 'cucumber-rails', ">= 1.2.0", :require => false
end
