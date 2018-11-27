# frozen_string_literal: true

namespace :purge_integration_errors do
  desc 'Process projects alerts'
  task purge_integration_errors: :environment do
    PurgeIntegrationErrorsJob.perform_later
  end
end
