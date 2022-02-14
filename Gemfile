source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.6', '>= 5.2.6.2'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use Puma as the app server
gem 'puma', '~> 4.3', '>= 4.3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.1', '>= 5.1.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2', '>= 4.2.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.7.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end

# ---

# Use jquery as the JavaScript library
gem 'jquery-rails', '>= 4.4.0'

group :development, :test do
  gem 'brakeman'
  gem 'rubocop'
  gem 'simplecov', require: false

  gem 'dotenv-rails', '>= 2.7.5'
  gem 'seed_dump'
  gem 'awesome_print'
end

gem 'rails-controller-testing', '>= 1.0.4', group: :test

group :development do
  # Use Capistrano for deployment
  gem 'capistrano', '~> 3.6'
  gem 'capistrano-passenger'
  gem 'capistrano-rails', '~> 1.2'
  gem 'capistrano-rvm'
  gem 'capistrano-clockwork'
end

gem 'bootstrap-sass', '>= 3.4.1'
gem 'font-awesome-sass', '>= 5.0.6.2'
gem 'simple_form', '>= 5.0.2'
gem 'will_paginate-bootstrap'

gem 'jcrop-rails-v2'
gem 'jpeg_camera', git: 'https://github.com/KPB-US/jpeg_camera.git'
#gem 'jpeg_camera', path: '../jpeg_camera'

gem 'paperclip', '~> 5.3.0'
gem 'prawn'

gem 'cancancan', '~> 2.0'
gem 'devise', '>= 4.7.1'
gem 'devise_ldap_authenticatable', '>= 0.8.6'
gem 'rolify'

gem 'rollbar'

gem 'haml'

gem 'cocoon'

gem 'mysql2'

gem 'rest-client', '>= 1.8.0' # for accessing mashape face detection api
gem 'remotipart'   # for ajax form posting

gem 'select2-rails', github: 'mfrederickson/select2-rails' # from another forker that has a later version of select2/select2

gem 'clockwork'
gem 'daemons'
gem 'tiny_tds', '~> 1.3.0'
