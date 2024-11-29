# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
SimpleCov.start do
  add_filter 'config/initializers/rack_profiler.rb'
  add_filter 'config/initializers/sidekiq.rb'
  add_filter 'app/controllers/webhook_integrations_controller.rb'
  minimum_coverage 100
end

require File.expand_path('../config/environment', __dir__)
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'
require 'shoulda/matchers'
require 'rspec/collection_matchers'
require 'webmock/rspec'
require 'jira-ruby'
require 'redis'

require 'sidekiq/testing'
Sidekiq::Testing.fake!
ActiveJob::Base.queue_adapter = :test

Rails.root.glob('spec/support/*.rb').each { |f| require f }

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

  config.before(:all) do
    spa_build = 'app/spa/build'
    FileUtils.mkdir_p(spa_build) unless File.directory?(spa_build)
    spa_index = "#{spa_build}/index.html"
    FileUtils.touch(spa_index) unless File.exist?(spa_index)
  end

  config.before do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start

    # rubocop:disable Rails/I18nLocaleAssignment
    I18n.locale = 'pt-BR'
    # rubocop:enable Rails/I18nLocaleAssignment
  end

  config.after do
    DatabaseCleaner.clean
  end

  config.include ActiveJob::TestHelper
  config.after do
    clear_enqueued_jobs
  end

  config.after(:all) do
    FileUtils.rm_rf(Rails.public_path.glob('uploads/tmp/*')) if Rails.env.test?
  end
end
