# frozen_string_literal: true

class TeamsController < AuthenticatedController
  before_action :user_gold_check

  before_action :assign_company
  before_action :assign_team, only: %i[show edit update replenishing_input statistics_tab]

  def show
    @team_members = @team.team_members.order(:name)
    @team_projects = ProjectsRepository.instance.all_projects_for_team(@team)
    @active_team_projects = @team_projects.active
    @projects_summary = ProjectsSummaryData.new(@team.projects)
    @projects_risk_chart_data = Highchart::ProjectRiskChartsAdapter.new(@team.projects)
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

  def statistics_tab
    @team_projects = ProjectsRepository.instance.all_projects_for_team(@team)

    project_statistics_chart_adapter = Highchart::ProjectStatisticsChartsAdapter.new(@team_projects, start_date_to_adapter, end_date_to_adapter, period_to_adapter)
    portfolio_statistics_chart_adapter = Highchart::PortfolioChartsAdapter.new(@team_projects, start_date_to_adapter, end_date_to_adapter)

    @x_axis = project_statistics_chart_adapter.x_axis

    build_scope_data(project_statistics_chart_adapter)
    build_leadtime_data(project_statistics_chart_adapter)
    build_block_data(project_statistics_chart_adapter)
    build_block_by_project_data(portfolio_statistics_chart_adapter)
    build_aging_by_project_data(portfolio_statistics_chart_adapter)

    respond_to { |format| format.js { render file: 'teams/statistics_tab.js.erb' } }
  end

  private

  def assign_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name)
  end

  def build_scope_data(project_statistics_chart_adapter)
    @scope_data = project_statistics_chart_adapter.scope_data_evolution_chart
    @scope_period_variation = Stats::StatisticsService.instance.compute_percentage_variation(@scope_data[0][:data].first, @scope_data[0][:data].last)
  end

  def build_leadtime_data(project_statistics_chart_adapter)
    @leadtime_data = project_statistics_chart_adapter.leadtime_data_evolution_chart(params[:leadtime_confidence])
    @leadtime_period_variation = Stats::StatisticsService.instance.compute_percentage_variation(@leadtime_data[0][:data].first, @leadtime_data[0][:data].last)
  end

  def build_block_data(project_statistics_chart_adapter)
    @block_data = project_statistics_chart_adapter.block_data_evolution_chart
    @block_period_variation = Stats::StatisticsService.instance.compute_percentage_variation(@block_data[0][:data].first, @block_data[0][:data].last)
  end

  def build_block_by_project_data(portfolio_statistics_chart_adapter)
    @block_by_project_data = portfolio_statistics_chart_adapter.block_count_by_project
    @block_by_project_x_axis = portfolio_statistics_chart_adapter.x_axis

    @block_by_project_variation = Stats::StatisticsService.instance.compute_percentage_variation(@block_by_project_data[0][:data].min || 0, @block_by_project_data[0][:data].max || 0)
  end

  def build_aging_by_project_data(portfolio_statistics_chart_adapter)
    @aging_by_project_data = portfolio_statistics_chart_adapter.aging_by_project
    @aging_by_project_x_axis = portfolio_statistics_chart_adapter.x_axis

    @aging_by_project_variation = Stats::StatisticsService.instance.compute_percentage_variation(@aging_by_project_data[0][:data].min || 0, @aging_by_project_data[0][:data].max || 0)
  end

  def start_date_to_adapter
    (params['start_date'] || @team_projects.map(&:start_date).min).to_date
  end

  def end_date_to_adapter
    (params['end_date'] || @team_projects.map(&:end_date).max).to_date
  end

  def period_to_adapter
    params['period'] || 'month'
  end
end
