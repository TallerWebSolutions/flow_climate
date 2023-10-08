# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.2.2'

gem 'rails'

gem 'bundler', require: false

gem 'addressable'
gem 'barnes'
gem 'carrierwave'
gem 'cloudinary'
gem 'coffee-rails'
gem 'devise'
gem 'discard'
gem 'figaro'
gem 'friendly_id'
gem 'graphiql-rails'
gem 'graphql'
gem 'histogram'
gem 'httparty'
gem 'jira-ruby', require: false
gem 'jquery-rails'
gem 'kaminari'
gem 'mini_magick'
gem 'net-imap'
gem 'net-pop'
gem 'net-smtp'
gem 'oj'
gem 'pg'
gem 'redis'
gem 'rollbar'
gem 'sidekiq', '= 6.5.7'
gem 'slack-notifier'
gem 'sprockets-rails', require: 'sprockets/railtie'
gem 'uglifier'
gem 'yui-compressor'
gem 'tzinfo-data'

group :test, :development do
  gem 'bullet'
  gem 'database_cleaner'
  gem 'fabrication'
  gem 'faker'
  gem 'parallel_tests'
  gem 'rails-controller-testing'
  gem 'rspec-collection_matchers'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'rubocop-graphql', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'shoulda-matchers'
  gem 'simplecov'
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
  gem 'puma_worker_killer'
  gem 'rails_12factor'
end
