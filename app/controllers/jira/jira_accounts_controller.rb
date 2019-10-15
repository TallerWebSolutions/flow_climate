# frozen_string_literal: true

module Jira
  class JiraAccountsController < AuthenticatedController
    before_action :assign_company
    before_action :assign_jira_account, only: %i[destroy show]

    def new
      @jira_account = JiraAccount.new(company_id: @company.id)
    end

    def create
      @jira_account = JiraAccount.new(jira_account_params.merge(company_id: @company.id))
      if @jira_account.save
        flash[:notice] = I18n.t('jira_accounts.create.success')
        redirect_to company_path(@company)
      else
        flash[:error] = I18n.t('jira_accounts.create.failed')
        render :new
      end
    end

    def destroy
      @jira_account.destroy
      @jira_accounts_list = @company.reload.jira_accounts.order(:created_at)
      render 'jira/jira_accounts/destroy'
    end

    def show
      @jira_custom_field_mappings = @jira_account.jira_custom_field_mappings.order(:custom_field_type)
    end

    private

    def jira_account_params
      params.require(:jira_jira_account).permit(:base_uri, :username, :api_token, :customer_domain)
    end

    def assign_jira_account
      @jira_account = @company.jira_accounts.find(params[:id])
    end
  end
end
