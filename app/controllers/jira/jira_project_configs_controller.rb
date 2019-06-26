# frozen_string_literal: true

module Jira
  class JiraProjectConfigsController < AuthenticatedController
    before_action :assign_company
    before_action :assign_project

    def new
      @jira_project_config = JiraProjectConfig.new
      respond_to { |format| format.js }
    end

    def create
      @jira_project_config = JiraProjectConfig.new(jira_project_config_params.merge(project: @project))
      flash[:error] = I18n.t('jira_project_config.validations.fix_version_name_uniqueness.message') unless @jira_project_config.save

      render 'jira/jira_project_configs/create'
    end

    def destroy
      @jira_project_config = JiraProjectConfig.find(params[:id])
      @jira_project_config.destroy
      render 'jira/jira_project_configs/destroy'
    end

    private

    def jira_project_config_params
      params.require(:jira_jira_project_config).permit(:fix_version_name)
    end

    def assign_project
      @project = Project.find(params[:project_id])
    end
  end
end
