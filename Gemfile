source 'http://rubygems.org'

gem 'rails', '3.0.3'

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
gem 'ckeditor', '3.4.2.pre'

# We better sanitize that HTML!
gem 'sanitize'

gem 'thinking-sphinx'
gem 'carrierwave'
gem 'mini_magick'
gem 'paperclip'
gem 'mysql2', "< 0.3.0"
#gem 'pg'
gem 'will_paginate', "< 3.0.0"
gem 'uuidtools'
gem 'fastercsv'
gem 'later_dude', '>= 0.3.1'
gem "hoptoad_notifier", '2.4.8'
gem "feedzirra", "~> 0.0.24"
gem "meta_search", "~> 1.0.5"
gem "meta_where", "~> 1.0.4"
gem "ruby-progressbar", :require => "progressbar"

group :cucumber, :test, :development do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'cucumber-rails'
  gem 'cucumber'
  gem 'rspec-rails'
  gem 'spork'
  gem 'launchy'
  gem 'ruby-debug'
  gem 'steak'
end

group :development do
  gem 'wirble'
end

