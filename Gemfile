# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.6.0'

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
gem 'oj'
gem 'histogram'
gem 'discard'
gem 'jira-ruby', require: false
gem 'attr_encrypted'
gem 'friendly_id', '~> 5.2.4'

group :test, :development do
  gem 'brakeman'
  gem 'database_cleaner'
  gem 'fabrication'
  gem 'faker'
  gem 'parser'
  gem 'rspec-collection_matchers'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'shoulda-matchers', '4.0.0.rc1'
  gem 'simplecov', require: false
  gem 'ruby-debug-ide', '~> 0.7.0.beta7'
  gem 'debase', '~> 0.2.3.beta3'
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
