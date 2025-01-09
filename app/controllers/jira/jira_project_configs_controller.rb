# frozen_string_literal: true

module Jira
  class JiraProjectConfigsController < ApplicationController
    before_action :assign_project
    before_action :assign_jira_project_config, only: %i[destroy synchronize_jira]

    def index
      prepend_view_path Rails.public_path
      render 'spa-build/index'
    end

    def new
      @jira_project_config = JiraProjectConfig.new
      @jira_product_configs = @project.products.map(&:jira_product_configs).flatten - @project.jira_project_configs.map(&:jira_product_config)
    end

    def edit
      prepend_view_path Rails.public_path
      render 'spa-build/index'
    end

    def create
      @jira_project_config = JiraProjectConfig.new(jira_project_config_params.merge(project: @project))
      flash[:error] = I18n.t('jira_project_config.validations.fix_version_name_uniqueness.message') unless @jira_project_config.save

      redirect_to company_project_jira_project_configs_path(@company, @project)
    end

    def synchronize_jira
      jira_account = @company.jira_accounts.first

      project_url = company_project_url(@company, @project)
      Jira::ProcessJiraProjectJob.perform_later(jira_account, @jira_project_config, Current.user.email_address, Current.user.full_name, project_url)
      flash.now[:notice] = I18n.t('general.enqueued')

      respond_to { |format| format.js { render 'jira/jira_project_configs/synchronize_jira' } }
    end

    def destroy
      @jira_project_config.destroy
      flash[:notice] = I18n.t('general.destroy.success')
      redirect_to company_project_jira_project_configs_path(@company, @project)
    end

    private

    def assign_jira_project_config
      @jira_project_config = JiraProjectConfig.find(params[:id])
    end

    def jira_project_config_params
      params.require(:jira_jira_project_config).permit(:jira_product_config_id, :fix_version_name)
    end

    def assign_project
      @project = Project.find(params[:project_id])
    end
  end
end
