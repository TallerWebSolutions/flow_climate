# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.0.1'

gem 'rails'

gem 'bundler', require: false

gem 'activerecord-session_store', git: 'https://github.com/rails/activerecord-session_store', branch: 'master'
gem 'addressable'
gem 'attr_encrypted'
gem 'barnes'
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
  gem 'bullet'
  gem 'database_cleaner'
  gem 'fabrication'
  gem 'faker'
  gem 'parallel_tests'
  gem 'parser'
  gem 'rails-controller-testing'
  gem 'rspec-collection_matchers'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'shoulda-matchers'
  gem 'simplecov', '~> 0.16.1'
  gem 'webmock'
end

group :development do
  gem 'annotate'
  gem 'flamegraph'
  gem 'listen'
  gem 'memory_profiler'
  gem 'rack-mini-profiler', require: false
  gem 'rails_best_practices', require: false
  gem 'rubycritic', require: false
  gem 'stackprof'
  gem 'traceroute'
  gem 'web-console'
end

group :test do
  gem 'rspec_junit_formatter'
end

group :production do
  gem 'newrelic_rpm'
  gem 'puma'
  gem 'rails_12factor'
end
