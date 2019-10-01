# frozen_string_literal: true

Rails.application.configure do
  config.cache_classes = false
  config.assets.compile = true
  config.eager_load = false
  config.consider_all_requests_local = true

  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=172800'
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.assets.debug = true
  config.assets.quiet = true
  config.action_view.raise_on_missing_translations = true

  host = 'http://127.0.0.1'
  config.action_mailer.default_url_options = { host: host, port: 3000 }
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :smtp

  logger = ActiveSupport::Logger.new(STDOUT)
  logger.formatter = config.log_formatter
  config.logger = ActiveSupport::TaggedLogging.new(logger)
  config.log_level = :debug

  config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
    Bullet.console = false
    Bullet.rails_logger = false
    Bullet.rollbar = false
    Bullet.add_footer = false
    Bullet.stacktrace_includes =%w(your_gem your_middleware)
    Bullet.stacktrace_excludes = ['their_gem', 'their_middleware', %w(my_file.rb my_method), ['my_file.rb', 16..20] ]
  end
end
