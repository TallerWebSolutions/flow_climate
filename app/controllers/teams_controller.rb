# frozen_string_literal: true

class TeamsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_team, only: %i[show edit update search_for_projects search_demands_to_flow_charts]

  def show
    @team_members = @team.team_members.order(:name)
    @team_projects = ProjectsRepository.instance.all_projects_for_team(@team)
    @active_team_projects = @team_projects.active
    @projects_summary = ProjectsSummaryObject.new(@team.projects)
    @pipefy_team_configs = @team.pipefy_team_configs.order(:username)
    assign_report_data(Time.zone.today.cweek, Time.zone.today.to_date.cwyear)
  end

  def new
    @team = Team.new(company: @company)
  end

  def create
    @team = Team.new(team_params.merge(company: @company))
    return redirect_to company_team_path(@company, @team) if @team.save
    render :new
  end

  def edit; end

  def update
    @team.update(team_params.merge(company: @company))
    return redirect_to company_path(@company) if @team.save
    render :edit
  end

  def search_for_projects
    @projects = ProjectsRepository.instance.add_query_to_projects_in_status(ProjectsRepository.instance.all_projects_for_team(@team), params[:status_filter])
    @projects_summary = ProjectsSummaryObject.new(@projects)
    respond_to { |format| format.js { render file: 'projects/projects_search.js.erb' } }
  end

  def search_demands_to_flow_charts
    @team_projects = ProjectsRepository.instance.all_projects_for_team(@team)
    @flow_report_data = FlowReportData.new(@team_projects, params[:week].to_i, params[:year].to_i)
    respond_to { |format| format.js { render file: 'teams/flow.js.erb' } }
  end

  private

  def assign_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name)
  end

  def assign_report_data(week, year)
    @report_data = ReportData.new(@team.projects)
    @strategic_report_data = StrategicReportData.new(@company, @team.projects, @team.active_monthly_available_hours_for_billable_types(@team.projects.pluck(:project_type).uniq))
    @projects_risk_alert_data = ProjectRiskData.new(@team.projects)
    @flow_report_data = FlowReportData.new(@team.projects, week, year)
  end
end
