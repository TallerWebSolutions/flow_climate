# frozen_string_literal: true

namespace :azure_api do
  desc 'Process Azure Issues'
  task process_azure_issues: :environment do
    Azure::AzureSyncJob.perform_later
  end
end
