# frozen_string_literal: true

class TeamsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_team, only: %i[show edit update search_for_projects]

  def show
    @team_members = @team.team_members.order(:name)
    @team_projects = @team.projects.order(end_date: :desc)
    @projects_summary = ProjectsSummaryObject.new(@team.projects)
    @report_data = ReportData.new(@team_projects) if @team_projects.present?
    @strategic_report_data = StrategicReportData.new(@company, @team.projects, @team.active_available_hours_for_billable_types(@team.projects.pluck(:project_type).uniq))
    @pipefy_team_configs = @team.pipefy_team_configs.order(:username)
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
    @projects = @team.projects.order(end_date: :desc)
    add_queries_to_projects
  end

  private

  def assign_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name)
  end
end
