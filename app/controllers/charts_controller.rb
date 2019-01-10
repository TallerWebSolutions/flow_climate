# frozen_string_literal: true

class ChartsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_projects
  before_action :assign_target_name

  def build_operational_charts
    @report_data = Highchart::OperationalChartsAdapter.new(@projects, params[:period])
    respond_to { |format| format.js { render file: 'charts/operational_charts.js.erb' } }
  end

  def build_strategic_charts
    @strategic_chart_data = Highchart::StrategicChartsAdapter.new(@company, @projects, @available_hours_in_month)
    respond_to { |format| format.js { render file: 'charts/strategic_charts.js.erb' } }
  end

  def build_status_report_charts
    @status_report_data = Highchart::StatusReportChartsAdapter.new(@projects, params[:period])
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
end
