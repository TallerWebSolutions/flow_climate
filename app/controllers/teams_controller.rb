# frozen_string_literal: true

class TeamsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_team, only: %i[show edit update search_for_projects search_demands_to_flow_charts search_demands_by_flow_status]

  def show
    @team_members = @team.team_members.order(:name)
    @team_projects = ProjectsRepository.instance.all_projects_for_team(@team)
    @active_team_projects = @team_projects.active
    @projects_summary = ProjectsSummaryObject.new(@team.projects)
    @pipefy_team_configs = @team.pipefy_team_configs.order(:username)
    @projects_risk_alert_data = ProjectRiskData.new(@team.projects)
    @team_demands = DemandsRepository.instance.demands_per_projects(@team_projects)
    assign_grouped_demands_informations
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

  def search_demands_by_flow_status
    @team_projects = ProjectsRepository.instance.all_projects_for_team(@team)
    demands_for_query_ids = DemandsRepository.instance.not_started_demands(@team_projects)
    @team_demands = Demand.where(id: demands_for_query_ids.map(&:id))
    assign_grouped_demands_informations
    respond_to { |format| format.js { render file: 'teams/search_demands_by_flow_status.js.erb' } }
  end

  private

  def assign_grouped_demands_informations
    @team_delivered_demands = DemandsRepository.instance.demands_finished_per_projects(@team_projects).order(end_date: :desc)
    @grouped_delivered_demands = @team_delivered_demands.grouped_end_date_by_month
    @grouped_customer_demands = @team_demands.grouped_by_customer
  end

  def assign_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name)
  end
end
