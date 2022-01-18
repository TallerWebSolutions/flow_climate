# frozen_string_literal: true

module Azure
  class AzureAccountsController < AuthenticatedController
    before_action :assign_company

    def synchronize_azure
      azure_account = @company.azure_accounts.first
      Azure::AzureSyncJob.perform_later(azure_account)
      flash[:notice] = I18n.t('general.enqueued')
      redirect_to company_path(@company)
    end
  end
end
