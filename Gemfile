# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.7.1'

gem 'rails'

gem 'addressable'
gem 'attr_encrypted'
gem 'carrierwave'
gem 'cloudinary'
gem 'coffee-rails'
gem 'devise'
gem 'discard'
gem 'figaro'
gem 'friendly_id'
gem 'histogram'
gem 'httparty'
gem 'jira-ruby', require: false
gem 'jquery-rails'
gem 'kaminari'
gem 'mini_magick'
gem 'oj'
gem 'pg'
gem 'rollbar'
gem 'sidekiq'
gem 'sidekiq-limit_fetch'
gem 'slack-notifier'
gem 'uglifier'
gem 'yui-compressor'

group :test, :development do
  gem 'brakeman'
  gem 'database_cleaner'
  gem 'fabrication'
  gem 'faker'
  gem 'knapsack_pro'
  gem 'parser', '~> 2.7', '>= 2.7.1.4', require: false
  gem 'rspec-collection_matchers'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'shoulda-matchers'
  gem 'simplecov-parallel'
  gem 'webmock'
end

group :development do
  gem 'annotate'
  gem 'bullet'
  gem 'flamegraph'
  gem 'listen'
  gem 'memory_profiler'
  gem 'rack-mini-profiler', require: false
  gem 'rails_best_practices'
  gem 'rubycritic', require: false
  gem 'stackprof'
  gem 'traceroute'
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
