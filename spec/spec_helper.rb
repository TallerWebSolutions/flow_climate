# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require 'knapsack_pro'

require 'simplecov'
SimpleCov.minimum_coverage 100
SimpleCov.start do
  add_filter 'config/initializers/rack_profiler.rb'
end

KnapsackPro::Hooks::Queue.before_queue do |_queue_id|
  SimpleCov.command_name("rspec_ci_node_#{KnapsackPro::Config::Env.ci_node_index}")
end

KnapsackPro::Adapters::RSpecAdapter.bind

require File.expand_path('../config/environment', __dir__)
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'
require 'shoulda/matchers'
require 'rspec/collection_matchers'
require 'webmock/rspec'
require 'jira-ruby'

Dir[Rails.root.join('spec/support/*.rb')].sort.each { |f| require f }

Rails.logger.level = 4
Devise.stretches = 1

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.order = :random
  config.profile_examples = 10
  config.fixture_path = Rails.root.join('spec/fixtures')
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.render_views

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view
  config.include ActiveSupport::Testing::TimeHelpers
  config.include Warden::Test::Helpers
  Warden.test_mode!

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.before(:suite) do
    DatabaseCleaner.clean_with(:transaction)
  end

  config.before do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, type: :feature) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before do
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end

  config.include ActiveJob::TestHelper
  config.after do
    clear_enqueued_jobs
  end

  config.after(:all) do
    FileUtils.rm_rf(Dir[Rails.root.join('public/uploads/tmp/*')]) if Rails.env.test?
  end
end
