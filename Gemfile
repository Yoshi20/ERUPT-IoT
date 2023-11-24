source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1.0'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.5.4'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  #See https://github.com/presidentbeef/brakeman
  gem 'brakeman'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]


# Added gems:
#See https://github.com/twbs/bootstrap-rubygem
gem 'jquery-rails'
gem 'bootstrap', '~> 4.3.1'

#See https://github.com/Angelmmiguel/material_icons
gem 'material_icons'

# See https://github.com/plataformatec/devise
gem 'devise'

# See https://github.com/laserlemon/figaro
gem 'figaro'

# See http://haml.info
gem 'haml-rails'

# See https://devcenter.heroku.com/articles/getting-started-with-rails4#visit-your-application
group :staging, :production do
  gem 'rails_12factor'
  # Workaround for a problem when using Ruby 3.1.2 with Rails 6
  gem 'net-smtp', require: false
  gem 'net-imap', require: false
  gem 'net-pop', require: false
end

# See https://nokogiri.org/
gem "nokogiri", ">= 1.11.0.rc4"

# See https://github.com/smartinez87/exception_notification
gem 'exception_notification'

# See https://github.com/svenfuchs/rails-i18n
gem 'rails-i18n', '~> 6.0.0' # For 6.0.0 or higher

# See https://github.com/tigrish/devise-i18n
gem 'devise-i18n'

# See https://github.com/iain/http_accept_language
gem 'http_accept_language'

# See https://github.com/ambethia/recaptcha
gem 'recaptcha'

# See https://github.com/pusher/push-notifications-ruby
gem 'pusher-push-notifications'

# See: https://github.com/jnunemaker/httparty
gem 'httparty'

# See https://github.com/mislav/will_paginate
gem 'will_paginate'

# See https://github.com/argerim/select2-rails
gem "select2-rails"

# For autom. deployment
gem 'mina'

# See https://github.com/collectiveidea/delayed_job
gem 'delayed_job_active_record'
gem "daemons"

# See https://github.com/cyu/rack-cors
gem 'rack-cors'
