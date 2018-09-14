# frozen_string_literal: true

module Jira
  class ProjectJiraConfigsController < AuthenticatedController
    before_action :assign_company
    before_action :assign_project

    def new
      @project_jira_config = ProjectJiraConfig.new
    end

    def create
      @project_jira_config = ProjectJiraConfig.new(project_jira_config_params.merge(project: @project))
      return redirect_to company_project_path(@company, @project) if @project_jira_config.save

      render :new
    end

    private

    def project_jira_config_params
      params.require(:project_jira_config).permit(:jira_account_domain, :jira_project_key, :fix_version_name, :team_id)
    end

    def assign_project
      @project = Project.find(params[:project_id])
    end
  end
end
