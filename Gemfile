source 'https://rubygems.org'
ruby '2.4.1'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.5', '>= 5.1.5'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0', '>= 5.0.7'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2', '>= 4.2.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails', '>= 4.3.1'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  gem 'brakeman', '>= 4.7.1'
  gem 'rubocop'
  gem 'simplecov', require: false

  gem 'dotenv-rails', '>= 2.2.1'
  gem 'seed_dump'
end

gem 'rails-controller-testing', '>= 1.0.2', group: :test

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 3.5.1'

  # Use Capistrano for deployment
  gem 'capistrano', '~> 3.6'
  gem 'capistrano-passenger'
  gem 'capistrano-rails', '~> 1.2'
  gem 'capistrano-rvm'
  gem 'capistrano-clockwork'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

gem 'bootstrap-sass', '>= 3.4.1'
gem 'font-awesome-sass', '>= 5.0.6.2'
gem 'simple_form', '>= 3.5.1'
gem 'will_paginate-bootstrap'

gem 'jcrop-rails-v2'
gem 'jpeg_camera', git: 'https://github.com/KPB-US/jpeg_camera.git'
#gem 'jpeg_camera', path: '../jpeg_camera'

gem 'paperclip', '~> 5.3.0'
gem 'prawn'

gem 'cancancan', '~> 2.0'
gem 'devise', '>= 4.6.0'
gem 'devise_ldap_authenticatable', '>= 0.8.6'
gem 'rolify'

gem 'rollbar'

gem 'haml'

gem 'cocoon'

gem 'mysql2'

gem 'rest-client'  , '>= 1.8.0' # for accessing mashape face detection api
gem 'remotipart'   # for ajax form posting

gem 'select2-rails', github: 'mfrederickson/select2-rails' # from another forker that has a later version of select2/select2

gem 'clockwork'
gem 'daemons'
