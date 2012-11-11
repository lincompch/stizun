source 'http://rubygems.org'

gem 'rails', '3.1.1'
gem 'jruby-openssl', :platform => :jruby
gem 'torquebox', :platform => :jruby
gem 'torquebox-server', :platform => :jruby
# Allows UJS with jQuery
gem 'jquery-rails'

# Offers Rails 2 f.error_messages etc. helpers on forms
gem 'dynamic_form'

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


platforms :ruby do
  gem 'mysql2'
  gem "feedzirra", "~> 0.0.24"
end

platforms :jruby do
  gem 'jdbc-mysql'
  gem 'activerecord-jdbcmysql-adapter'
  gem 'trinidad'
end

gem 'erubis'

gem 'will_paginate', "3.0.0"
gem 'uuidtools'
gem 'later_dude', '>= 0.3.1'
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
  gem 'factory_girl'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'pickle'
  gem 'database_cleaner'
  gem 'cucumber'
  gem 'rspec-rails'
  gem 'spork'
  gem 'launchy'
  gem 'ZenTest'
  gem 'pry'
  gem 'warbler', :platform => :jruby
  #gem 'therubyracer', '>= 0.8.2'
end

group :test do 
  gem 'cucumber-rails', ">= 1.2.0", :require => false
end
