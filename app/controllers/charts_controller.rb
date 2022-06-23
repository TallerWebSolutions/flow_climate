# frozen_string_literal: true

class ChartsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_projects
  before_action :assign_target_name
  before_action :assign_filter_parameters_to_charts
  before_action :assign_leadtime_confidence

  def build_strategic_charts
    @strategic_chart_data = Highchart::StrategicChartsAdapter.new(@company, teams, @projects, demands, @start_date, @end_date, @period)
    respond_to { |format| format.js { render 'charts/strategic_charts' } }
  end

  private

  def demands
    @demands ||= Demand.where(id: @projects.map { |project| project.demands.map(&:id) }.flatten)
  end

  def assign_projects
    @projects = Project.where(id: projects_ids)
    return if @projects.blank?

    teams = @projects.includes(:team).map(&:team).uniq.compact
    @available_hours_in_month = 0
    @available_hours_in_month = teams.sum(&:available_hours_in_month_for) if teams.present?
  end

  def teams
    @teams ||= Team.where(id: params[:teams_ids].split(','))
  end

  def assign_target_name
    @target_name = params[:target_name]
  end

  def assign_filter_parameters_to_charts
    @period = params[:period] || 'month'
    @start_date = start_date
    @end_date = end_date
  end

  def start_date
    start_date = params[:start_date]&.to_date || [@projects.map(&:start_date).min, 3.months.ago.to_date].compact.max
    TimeService.instance.start_of_period_for_date(start_date, @period)
  end

  def end_date
    end_date = params[:end_date]&.to_date || @projects.map(&:end_date).max || Time.zone.today
    TimeService.instance.end_of_period_for_date(end_date, @period)
  end

  def assign_leadtime_confidence
    @leadtime_confidence = params[:leadtime_confidence].to_i
    @leadtime_confidence = 80 unless @leadtime_confidence.positive?
  end

  def projects_ids
    return [] if params[:projects_ids].blank?

    params[:projects_ids].split(',')
  end
end
