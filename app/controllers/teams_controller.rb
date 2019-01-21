# frozen_string_literal: true

class TeamsController < AuthenticatedController
  before_action :user_gold_check

  before_action :assign_company
  before_action :assign_team, only: %i[show edit update]

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

  private

  def assign_chart_informations
    @flow_report_data = Highchart::FlowChartsAdapter.new(@team_projects, Time.zone.today.cweek, Time.zone.today.cwyear)
  end

  def assign_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name)
  end
end
