# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.6.0'

gem 'rails'

gem 'attr_encrypted'
gem 'carrierwave', '~> 1.0'
gem 'coffee-rails'
gem 'devise'
gem 'discard'
gem 'figaro'
gem 'friendly_id', '~> 5.2.4'
gem 'histogram'
gem 'httparty'
gem 'jira-ruby', require: false
gem 'jquery-rails'
gem 'mini_magick'
gem 'oj'
gem 'pg'
gem 'rollbar'
gem 'sidekiq'
gem 'therubyracer', platforms: :ruby
gem 'uglifier'
gem 'webmock'
gem 'yui-compressor'

group :test, :development do
  gem 'brakeman'
  gem 'database_cleaner'
  gem 'debase', '~> 0.2.3.beta3'
  gem 'fabrication'
  gem 'faker'
  gem 'parser'
  gem 'rspec-collection_matchers'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'ruby-debug-ide', '~> 0.7.0.beta7'
  gem 'shoulda-matchers', '4.0.0.rc1'
  gem 'simplecov', require: false
end

group :development do
  gem 'annotate'
  gem 'listen'
  gem 'web-console'
end

group :test do
  gem 'rails-controller-testing'
  gem 'rspec_junit_formatter'
end

group :production do
  gem 'puma'
  gem 'rails_12factor'
end
