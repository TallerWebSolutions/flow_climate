# frozen_string_literal: true

module Azure
  class AzureAccountsController < AuthenticatedController
    before_action :assign_company

    def synchronize_azure
      azure_account = @company.azure_account
      Azure::AzureSyncJob.perform_now(azure_account, current_user.email, current_user.full_name)
      flash[:notice] = I18n.t('general.enqueued')
      redirect_to company_path(@company)
    end
  end
end
