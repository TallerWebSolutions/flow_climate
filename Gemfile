# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.4.3'

gem 'rails'

gem 'coffee-rails'
gem 'devise'
gem 'figaro'
gem 'jquery-rails'
gem 'pg'
gem 'sidekiq'
gem 'therubyracer', platforms: :ruby
gem 'uglifier'
gem 'yui-compressor'
gem 'httparty'
gem 'webmock'
gem 'rollbar'
gem 'oj', '~> 2.16.1'
gem 'histogram'

group :test, :development do
  gem 'brakeman'
  gem 'database_cleaner'
  gem 'fabrication'
  gem 'faker'
  gem 'parser'
  gem 'rspec-collection_matchers'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'shoulda-matchers'
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
