# frozen_string_literal: true

class TeamsController < AuthenticatedController
  before_action :user_gold_check

  before_action :assign_company
  before_action :assign_team, only: %i[show edit update replenishing_input destroy]

  def show
    assign_team_objects

    @start_date = build_limit_date(@team_projects.map(&:start_date).min)
    @end_date = build_limit_date(@team_projects.map(&:end_date).max)
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

  def replenishing_input
    @replenishing_data = ReplenishingData.new(@team)

    render 'teams/replenishing_input.js.erb'
  end

  def destroy
    team_name = @team.name

    @team.destroy
    if @team.errors.full_messages.present?
      flash[:error] = @team.errors.full_messages.join(' | ')
    else
      flash[:notice] = I18n.t('teams.destroy.success', team_name: team_name)
    end

    @teams = @company.teams.order(:name)
    respond_to { |format| format.js { render 'teams/destroy' } }
  end

  private

  def assign_team_objects
    @team_members = @team.team_members.order(:name)
    @team_projects = ProjectsRepository.instance.all_projects_for_team(@team)
    @active_team_projects = @team_projects.active
    @projects_summary = ProjectsSummaryData.new(@team.projects)
    @projects_risk_chart_data = Highchart::ProjectRiskChartsAdapter.new(@team.projects)
    @slack_configurations = @team.slack_configurations.order(:created_at)
  end

  def build_limit_date(date)
    [date, 4.weeks.ago].compact.max.to_date
  end

  def assign_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name, :max_work_in_progress)
  end
end
