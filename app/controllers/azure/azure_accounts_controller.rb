# frozen_string_literal: true

module Azure
  class AzureAccountsController < AuthenticatedController
    before_action :assign_company

    def synchronize_azure
      azure_account = @company.azure_account
      Azure::AzureSyncJob.perform_later(azure_account, current_user.email, current_user.full_name)
      flash[:notice] = I18n.t('general.enqueued')
      redirect_to company_path(@company)
    end

    def edit
      @azure_account = @company.azure_account
    end

    def update
      @azure_account = @company.azure_account

      if @azure_account.update(azure_account_params)
        flash[:notice] = I18n.t('azure_accounts.edit.success')
        redirect_to edit_company_azure_account_path(@company, @azure_account)
      else
        flash[:error] = I18n.t('azure_accounts.edit.failure')
        render :edit
      end
    end

    private

    def azure_account_params
      params.require(:azure_azure_account).permit(:azure_organization, :username, :azure_work_item_query)
    end
  end
end
