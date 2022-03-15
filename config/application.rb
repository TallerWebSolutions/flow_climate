# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
# require "active_storage/engine"
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require "action_mailbox/engine"
# require "action_text/engine"
require 'action_view/railtie'
require 'action_cable/engine'
require 'rails/test_unit/railtie'
require 'sprockets/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FlowControl
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0
    config.active_support.default_message_encryptor_serializer = :hybrid
    config.active_record.legacy_connection_handling = false
    config.action_controller.default_protect_from_forgery = true

    config.i18n.enforce_available_locales = false
    config.i18n.available_locales = %w[pt-BR en coca]
    config.i18n.default_locale = 'pt-BR'

    config.time_zone = 'Brasilia'

    config.active_record.schema_format = :sql

    config.active_job.queue_adapter = :sidekiq
    config.action_mailer.delivery_method = :smtp

    Rails.autoloaders.main.ignore(Rails.root.join('app/spa'))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
