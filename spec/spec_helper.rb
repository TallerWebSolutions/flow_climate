# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'

SimpleCov.start 'rails' do
  minimum_coverage 100
  add_group 'Repositories', 'app/repositories'
  add_group 'Services', 'app/services'
  add_group 'Uploaders', 'app/uploaders'
end
SimpleCov.command_name 'RSpec'

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
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation, except: [ActiveRecord::InternalMetadata.table_name]
  end

  config.around do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.include ActiveJob::TestHelper
  config.after do
    clear_enqueued_jobs
  end

  config.after(:all) do
    FileUtils.rm_rf(Dir[Rails.root.join('public/uploads/tmp/*')]) if Rails.env.test?
  end
end
