source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.1"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 6.0", ">= 6.0.3"
# Use postgresql as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"
# Use Puma as the app server
gem "puma", "~> 4.1"
# Use SCSS for stylesheets
gem "sass-rails", ">= 6"
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "webpacker", "~> 4.0"
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.7"
# Use Redis adapter to run Action Cable in production
# TODO Install foreman, and add a Procfile
gem "redis", "~> 4.0"
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.2", require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  # TODO Consider using config/credentials.yml.enc
  gem "dotenv-rails", "~> 2.1", ">= 2.1.1"
  gem "faker", "~> 2.10", ">= 2.10.1"
  gem "bullet", "~> 6.1"
  gem "standard", "~> 0.2.2"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 3.3.0"
  gem "listen", ">= 3.0.5", "< 3.2"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 2.15"
  gem "selenium-webdriver"
  # Easy installation and use of web drivers to run system tests with browsers
  gem "webdrivers"
  gem "vcr", "~> 5.1"
  gem "webmock", "~> 3.8", ">= 3.8.3"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem "devise", "~> 4.7", ">= 4.7.1"
gem "acts-as-taggable-on", "~> 6.5"
gem "paper_trail", "~> 10.3", ">= 10.3.1"
gem "pundit", "~> 2.1"
gem "friendly_id", "~> 5.3"
gem "kaminari", "~> 1.2"
gem "ransack", "~> 2.3", ">= 2.3.2"
gem "redcarpet", "~> 3.5"
gem "acts_as_list", "~> 1.0", ">= 1.0.1"
gem "strong_migrations", "~> 0.6.4"
gem "data_migrate", "~> 6.3"
gem "sidekiq", "~> 6.0", ">= 6.0.7"
gem "twilio-ruby", "~> 5.33", ">= 5.33.1"
gem "foreman", "~> 0.87.1"
gem "phonelib", "~> 0.6.43"
gem "sendgrid-ruby", "~> 6.2"
