# frozen_string_literal: true

module Jira
  class JiraAccountsController < AuthenticatedController
    before_action :assign_company

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
      @jira_account = JiraAccount.find(params[:id])
      @jira_account.destroy
      @jira_accounts_list = @company.reload.jira_accounts.order(:created_at)
      render 'jira/jira_accounts/destroy'
    end

    private

    def jira_account_params
      params.require(:jira_jira_account).permit(:base_uri, :username, :password, :customer_domain)
    end
  end
end
