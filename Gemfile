source 'http://rubygems.org'

gem 'rails', '3.1.1rc1'

# Allows UJS with jQuery
gem 'jquery-rails'

# Offers Rails 2 f.error_messages etc. helpers on forms
gem 'dynamic_form'

# Hacked to work with Rails 3 thanks to rails3-generators
# But need to consider Devise instead

gem 'devise'
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
gem 'paperclip'
gem 'mysql2'
gem 'erubis'
gem 'will_paginate', "3.0.0"
gem 'uuidtools'
gem 'later_dude', '>= 0.3.1'
gem "feedzirra", "~> 0.0.24"
gem "ruby-progressbar", :require => "progressbar"
gem 'nokogiri' 

group :assets do
  gem 'sass-rails', " ~> 3.1.0"
  gem 'coffee-rails', " ~> 3.1.0"
  gem 'uglifier'
end

group :cucumber, :test, :development do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'cucumber-rails'
  gem 'cucumber'
  gem 'rspec-rails'
  gem 'spork', '0.9.0.rc9'
  gem 'launchy'
  gem 'ruby-debug19'
  gem 'ZenTest'
  gem 'pry'
  gem 'pry-doc'
  gem 'therubyracer', '>= 0.8.2'
end
