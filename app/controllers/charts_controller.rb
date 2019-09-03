# frozen_string_literal: true

class ChartsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_projects
  before_action :assign_team, only: :build_operational_charts
  before_action :assign_target_name
  before_action :assign_filter_parameters_to_charts
  before_action :assign_leadtime_confidence

  def build_operational_charts
    @report_data = {}
    @report_data = Highchart::OperationalChartsAdapter.new(@projects, @start_date, @end_date, @period) if @projects.present?
    @team_chart_data = Highchart::TeamChartsAdapter.new(@team, @start_date, @end_date, @period) if @team.present?

    @status_report_data = {}
    @status_report_data = Highchart::StatusReportChartsAdapter.new(@projects, @start_date, @end_date, @period) if @projects.present?

    @portfolio_data = Highchart::PortfolioChartsAdapter.new(@projects, @start_date, @end_date, '') if @projects.present?

    respond_to { |format| format.js { render 'charts/operational_charts' } }
  end

  def build_strategic_charts
    @strategic_chart_data = Highchart::StrategicChartsAdapter.new(@company, teams, @projects, @start_date, @end_date, @period)
    respond_to { |format| format.js { render 'charts/strategic_charts' } }
  end

  def statistics_charts
    if @projects.present?
      project_statistics_chart_adapter = Highchart::ProjectStatisticsChartsAdapter.new(@projects, @start_date, @end_date, @period, params[:project_status])
      portfolio_statistics_chart_adapter = Highchart::PortfolioChartsAdapter.new(@projects, @start_date, @end_date, params[:project_status])

      @x_axis = project_statistics_chart_adapter.x_axis
      @project_statistics_data = ProjectStatisticsData.new(project_statistics_chart_adapter, @leadtime_confidence)
      @portfolio_statistics_data = PortfolioStatisticsData.new(portfolio_statistics_chart_adapter)
      project_consolidations = ProjectConsolidation.where(project: @projects.map(&:id)).order(:consolidation_date)
      @projects_consolidations_charts_adapter = Highchart::ProjectsConsolidationsChartsAdapter.new(project_consolidations, @start_date, @end_date)
    end

    respond_to { |format| format.js { render 'charts/statistics_tab' } }
  end

  private

  def assign_projects
    @projects = Project.where(id: params[:projects_ids].split(','))
    return if @projects.blank?

    teams = @projects.includes(:team).map(&:team).uniq.compact
    @available_hours_in_month = 0
    @available_hours_in_month = teams.sum { |team| team.active_monthly_available_hours_for_billable_types(@projects.pluck(:project_type).uniq) } if teams.present?
  end

  def assign_team
    @team = Team.find_by(id: params[:team_id])
  end

  def teams
    @teams ||= Team.where(id: params[:teams_ids].split(','))
  end

  def assign_target_name
    @target_name = params[:target_name]
  end

  def assign_filter_parameters_to_charts
    @start_date = params[:start_date]&.to_date || [@projects.map(&:start_date).min, 3.months.ago.to_date].compact.max
    @end_date = params[:end_date]&.to_date || @projects.map(&:end_date).max
    @period = params[:period] || 'month'
  end

  def assign_leadtime_confidence
    @leadtime_confidence = params[:leadtime_confidence].to_i
    @leadtime_confidence = 80 unless @leadtime_confidence.positive?
  end
end
