# frozen_string_literal: true

class TeamsController < DemandsListController
  before_action :assign_team, except: %i[new index]

  def index
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end

  def show
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end

  def new
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end

  def edit
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end

  def team_projects_tab
    executing_projects = @team.projects.running

    @projects_lead_time_in_time = []
    @projects_risk_in_time = []
    @projects_risk_in_time_team_based = []
    build_projects_lead_time_in_time_array(executing_projects)

    start_date = 6.months.ago.to_date.beginning_of_month
    end_date = Time.zone.today
    projects_last_six_months = @team.projects.not_cancelled.active_in_period(start_date, end_date)
    @last_six_months_hours_per_project = Highchart::ProjectsChartAdapter.new(projects_last_six_months).hours_per_project_in_period(start_date, end_date)

    respond_to { |format| format.js { render 'teams/team_projects_tab' } }
  end

  def dashboard_tab
    charts_demands
    respond_to { |format| format.js { render 'teams/dashboards/dashboard_tab' } }
  end

  def dashboard_page_two
    charts_demands
    @team_chart_data = Highchart::TeamChartsAdapter.new(@team, start_date, end_date, 'week')

    respond_to { |format| format.js { render 'teams/dashboards/dashboard_page_two' } }
  end

  def dashboard_page_three
    @demands_chart_adapter = Highchart::DemandsChartsAdapter.new(charts_demands, start_date, Time.zone.today, 'week')
    @array_of_dates = @demands_chart_adapter.x_axis

    respond_to { |format| format.js { render 'teams/dashboards/dashboard_page_three' } }
  end

  def dashboard_page_four
    @strategic_chart_data = Highchart::StrategicChartsAdapter.new(@company, [@team], @team.projects, charts_demands, start_date, end_date, 'month')
    @target_name = @team.name
    @array_of_dates = @strategic_chart_data.x_axis

    respond_to { |format| format.js { render 'teams/dashboards/dashboard_page_four' } }
  end

  def dashboard_page_five
    active_memberships = @team.memberships.active.developer.includes([:team_member])

    build_membership_lead_time_in_time_array(active_memberships)

    respond_to { |format| format.js { render 'teams/dashboards/dashboard_page_five' } }
  end

  def update_cache
    start_date = @team.start_date
    end_date = @team.end_date

    cache_date_arrays = TimeService.instance.days_between_of(start_date, end_date)
    cache_date_arrays.each { |cache_date| Consolidations::TeamConsolidationJob.perform_later(@team, cache_date.beginning_of_day) }

    flash[:notice] = I18n.t('general.enqueued')

    redirect_to company_team_path(@company, @team)
  end

  private

  def build_projects_lead_time_in_time_array(executing_projects)
    array_of_dates = []

    executing_projects.each do |project|
      project_lead_times_hash = compute_project_lead_times(project)
      array_of_dates << project_lead_times_hash[:project_period]
      @projects_lead_time_in_time << project_lead_times_hash[:project_data]

      @projects_risk_in_time << { name: project.name, data: ProjectService.instance.risk_data_by_week(project) }
      @projects_risk_in_time_team_based << { name: project.name, data: ProjectService.instance.risk_data_by_week_team_data(project) }
    end

    build_x_axis_index(array_of_dates)
  end

  def build_membership_lead_time_in_time_array(active_memberships)
    @memberships_lead_time_in_time = []
    array_of_dates = []
    active_memberships.includes([:demands]).each do |membership|
      membership_lead_times_hash = compute_membership_lead_times(membership)
      array_of_dates << membership_lead_times_hash[:membership_period]
      @memberships_lead_time_in_time << membership_lead_times_hash[:membership_data]
    end

    build_x_axis_index(array_of_dates)
  end

  def build_x_axis_index(array_of_dates)
    min_date = array_of_dates.flatten.min
    max_date = array_of_dates.flatten.max

    all_period = TimeService.instance.months_between_of(min_date, max_date)

    @x_axis_index = all_period.map { |value| all_period.find_index(value) + 1 }.flatten
  end

  def compute_project_lead_times(project)
    project_demands = project.demands
    project_period = TimeService.instance.weeks_between_of(project.start_date, Time.zone.today)

    statistics_informations = Flow::StatisticsFlowInformation.new(project_demands)
    project_period.each { |analysed_date| statistics_informations.statistics_flow_behaviour(analysed_date) }

    { project_period: project_period, project_data: { name: project.name, data: statistics_informations.lead_time_accumulated } }
  end

  def compute_membership_lead_times(membership)
    membership_demands = membership.demands
    start_date = [membership.start_date, membership_demands.kept.filter_map(&:commitment_date).min].compact.max
    membership_period = TimeService.instance.weeks_between_of(start_date, Time.zone.today)

    statistics_informations = Flow::StatisticsFlowInformation.new(membership_demands)
    membership_period.each { |analysed_date| statistics_informations.statistics_flow_behaviour(analysed_date) }

    { membership_period: membership_period, membership_data: { name: membership.team_member_name, data: statistics_informations.lead_time_accumulated } }
  end

  def charts_demands
    @charts_demands ||= @team.demands.kept.includes([:product]).to_dates(6.months.ago, Time.zone.now.end_of_day)
  end

  def start_date
    charts_demands.filter_map(&:end_date).min || Time.zone.today
  end

  def end_date
    charts_demands.filter_map(&:end_date).max || Time.zone.today
  end

  def assign_team
    @team = @company.teams.find(params[:id])
  end
end
