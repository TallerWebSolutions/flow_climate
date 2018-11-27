# frozen_string_literal: true

class TeamsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_team, only: %i[show edit update search_for_projects search_demands_to_flow_charts]

  def show
    @team_members = @team.team_members.order(:name)
    @team_projects = ProjectsRepository.instance.all_projects_for_team(@team)
    @active_team_projects = @team_projects.active
    @projects_summary = ProjectsSummaryData.new(@team.projects)
    @projects_risk_chart_data = Highchart::ProjectRiskChartsAdapter.new(@team.projects)
    assign_chart_informations
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
    @projects_summary = ProjectsSummaryData.new(@projects)
    respond_to { |format| format.js { render file: 'projects/projects_search.js.erb' } }
  end

  def search_demands_to_flow_charts
    @team_projects = ProjectsRepository.instance.all_projects_for_team(@team)
    @flow_report_data = Highchart::FlowChartsAdapter.new(@team_projects, params[:week].to_i, params[:year].to_i)
    respond_to { |format| format.js { render file: 'teams/flow.js.erb' } }
  end

  private

  def assign_chart_informations
    @grouped_delivered_demands = @demands.grouped_end_date_by_month if params[:grouped_by_month] == 'true'
    @grouped_customer_demands = @demands.grouped_by_customer if params[:grouped_by_customer] == 'true'
    @flow_report_data = Highchart::FlowChartsAdapter.new(@team_projects, Time.zone.today.cweek, Time.zone.today.cwyear)
  end

  def assign_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name)
  end
end
