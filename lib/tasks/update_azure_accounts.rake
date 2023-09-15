# frozen_string_literal: true

namespace :azure do
  desc 'update azure accounts'

  task update_azure_accounts: :environment do
    Azure::AzureAccount.find_each do |account|
      Azure::AzureSyncJob.perform_later(account, nil, nil)
    end
  end
end
