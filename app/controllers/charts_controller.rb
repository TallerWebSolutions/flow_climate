# frozen_string_literal: true

class ChartsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_projects

  def build_operational_charts
    @report_data = Highchart::OperationalChartsAdapter.new(@projects)
    respond_to { |format| format.js { render file: 'teams/operational_charts.js.erb' } }
  end

  def build_strategic_charts
    @strategic_report_data = Highchart::StrategicChartsAdapter.new(@company, @projects, @available_hours_in_month)
    respond_to { |format| format.js { render file: 'teams/strategic_charts.js.erb' } }
  end

  def build_status_report_charts
    @status_report_data = Highchart::StatusReportChartsAdapter.new(@projects)
    respond_to { |format| format.js { render file: 'teams/status_report_charts.js.erb' } }
  end

  private

  def assign_projects
    team = Team.find(params[:team_id])
    @projects = team.projects
    @target_name = team.name
    @available_hours_in_month = team.active_monthly_available_hours_for_billable_types(team.projects.pluck(:project_type).uniq)
  end
end
