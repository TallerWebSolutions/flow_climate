# frozen_string_literal: true

class ChartsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_projects
  before_action :assign_target_name

  def build_operational_charts
    @report_data = {}
    @report_data = Highchart::OperationalChartsAdapter.new(@projects, start_date_to_charts, end_date_to_charts, period_to_chart) if @projects.present?
    # @portfolio_data = Highchart::PortfolioChartsAdapter.new(@projects, params[:period])
    respond_to { |format| format.js { render file: 'charts/operational_charts.js.erb' } }
  end

  def build_strategic_charts
    @strategic_chart_data = Highchart::StrategicChartsAdapter.new(@company, @projects, @available_hours_in_month)
    respond_to { |format| format.js { render file: 'charts/strategic_charts.js.erb' } }
  end

  def build_status_report_charts
    @status_report_data = {}
    @status_report_data = Highchart::StatusReportChartsAdapter.new(@projects, start_date_to_charts, end_date_to_charts, period_to_chart) if @projects.present?
    respond_to { |format| format.js { render file: 'charts/status_report_charts.js.erb' } }
  end

  private

  def assign_projects
    @projects = Project.where(id: params[:projects_ids].split(','))
    return if @projects.blank?

    team = @projects.last.current_team
    @target_name = params[:target_name]
    @available_hours_in_month = team.active_monthly_available_hours_for_billable_types(team.projects.pluck(:project_type).uniq)
  end

  def assign_target_name
    @target_name = params[:target_name]
  end

  def start_date_to_charts
    params[:start_date]&.to_date || @projects.map(&:start_date).min
  end

  def end_date_to_charts
    params[:end_date]&.to_date || @projects.map(&:end_date).max
  end

  def period_to_chart
    params[:period] || :week
  end
end
