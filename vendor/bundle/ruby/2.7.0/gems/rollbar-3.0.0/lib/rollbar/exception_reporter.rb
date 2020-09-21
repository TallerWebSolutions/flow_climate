module Rollbar
  module ExceptionReporter # :nodoc:
    def report_exception_to_rollbar(env, exception)
      return unless capture_uncaught?

      log_exception_message(exception)

      exception_data = exception_data(exception)

      if exception_data.is_a?(Hash)
        env['rollbar.exception_uuid'] = exception_data[:uuid]
        Rollbar.log_debug "[Rollbar] Exception uuid saved in env: #{exception_data[:uuid]}"
      elsif exception_data == 'disabled'
        Rollbar.log_debug '[Rollbar] Exception not reported because Rollbar is disabled'
      elsif exception_data == 'ignored'
        Rollbar.log_debug '[Rollbar] Exception not reported because it was ignored'
      end
    rescue StandardError => e
      Rollbar.log_warning "[Rollbar] Exception while reporting exception to Rollbar: #{e.message}"
    end

    def capture_uncaught?
      Rollbar.configuration.capture_uncaught != false
    end

    def log_exception_message(exception)
      exception_message = exception.respond_to?(:message) ? exception.message : 'No Exception Message'
      Rollbar.log_debug "[Rollbar] Reporting exception: #{exception_message}"
    end

    def exception_data(exception)
      Rollbar.log(Rollbar.configuration.uncaught_exception_level, exception, :use_exception_level_filters => true)
    end
  end
end
