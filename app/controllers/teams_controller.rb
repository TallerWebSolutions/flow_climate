# frozen_string_literal: true

class TeamsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_team, only: %i[show edit update search_for_projects]

  def show
    @team_members = @team.team_members.order(:name)
    @team_projects = @team.projects.order(end_date: :desc)
    @projects_summary = ProjectsSummaryObject.new(@team.projects)
    @report_data = ReportData.new(@team_projects) if @team_projects.present?
    @hours_per_demand_data = [{ name: I18n.t('projects.charts.hours_per_demand.ylabel'), data: @team_projects.map(&:avg_hours_per_demand) }]
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
    @projects = @projects.where(status: params[:status_filter]) if params[:status_filter] != 'all'
    @projects = @projects.order(end_date: :desc)
    @projects_summary = ProjectsSummaryObject.new(@projects)
    respond_to { |format| format.js { render file: 'projects/projects_search.js.erb' } }
  end

  private

  def assign_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name)
  end
end
