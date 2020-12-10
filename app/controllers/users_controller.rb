# frozen_string_literal: true

class UsersController < AuthenticatedController
  before_action :check_admin, only: %i[toggle_admin admin_dashboard]
  before_action :assign_user, only: %i[toggle_admin show edit update companies]

  def admin_dashboard
    @users_list = User.all.order(%i[last_name first_name])
    @companies_list = Company.all.order(:name)
  end

  def activate_email_notifications
    current_user.update(email_notifications: true)
    respond_to { |format| format.js { render 'users/reload_notifications' } }
  end

  def deactivate_email_notifications
    current_user.update(email_notifications: false)
    respond_to { |format| format.js { render 'users/reload_notifications' } }
  end

  def toggle_admin
    @user.toggle_admin
    redirect_to admin_dashboard_users_path
  end

  def show
    build_page_objects
  end

  def edit
    @companies_list = @user.companies.order(:name)
  end

  def update
    return redirect_to user_path(@user) if @user.update(user_params)

    @companies_list = @user.companies.order(:name)
    assign_user_dependencies
    redirect_to user_path(@user)
  end

  def companies
    @companies = @user.companies.order(:name)

    render 'companies/index'
  end

  def home
    @user = current_user
    build_page_objects

    render 'users/show'
  end

  private

  def build_page_objects
    @companies_list = @user.companies.order(:name)
    @company = @user.last_company || @user.companies.last

    assign_manager_charts_objects(@company) if @company.present?

    assign_team_member_dependencies
    assign_user_dependencies
    assign_stats_info
  end

  def assign_manager_charts_objects(company)
    projects = running_projects(company)
    start_manager_charts_hashes
    projects.each do |project|
      start_manager_charts_arrays(project)

      consolidations = Consolidations::ProjectConsolidation.for_project(project).weekly_data.order(:consolidation_date)
      build_consolidations(project, consolidations)
    end
  end

  def assign_team_member_dependencies
    @pairing_chart = {}
    @teams = []
    return if @user.team_member.blank? || @company.role_for_user(@user).manager?

    build_pairing_chart

    @member_teams = @user.team_member.teams.order(:name)
    @demand_blocks = @user.team_member.demand_blocks.order(block_time: :desc).first(5)
    @member_projects = @user.team_member.projects.active.order(end_date: :desc).last(5)

    build_member_effort_chart(@user.team_member)
  end

  def build_member_effort_chart(team_member)
    @member_effort_chart = []
    @member_pull_interval_average_chart = []

    @operations_dashboards = Dashboards::OperationsDashboard.where(team_member: team_member, last_data_in_month: true).order(:dashboard_date)

    @member_effort_chart << { name: team_member.name, data: @operations_dashboards.map { |dashboard| dashboard.member_effort.to_f } }
    @member_pull_interval_average_chart << { name: team_member.name, data: @operations_dashboards.map { |dashboard| dashboard.pull_interval.to_f } }
  end

  def build_pairing_chart
    @user.team_member.pairing_members(Time.zone.today).each { |name, qty| @pairing_chart[name] = qty }
  end

  def assign_user_dependencies
    @user_plans = @user.user_plans.order(finish_at: :desc)
  end

  def assign_stats_info
    user_demands = @user.demands

    @array_of_dates = TimeService.instance.months_between_of(start_date(user_demands), Time.zone.today.end_of_month)

    @demands_chart_adapter = Highchart::DemandsChartsAdapter.new(member_demands, start_date(user_demands), Time.zone.today, 'month')

    @statistics_information = Flow::StatisticsFlowInformations.new(user_demands)

    @array_of_dates.each { |analysed_date| @statistics_information.statistics_flow_behaviour(analysed_date) }
  end

  def start_date(user_demands)
    user_demands.map(&:end_date).compact.min || Time.zone.now
  end

  def member_demands
    member_demands = Demand.none
    member_demands = Demand.where(id: @user.team_member.demands_for_role) if @user.team_member.present?
    member_demands
  end

  def user_params
    params.require(:user).permit(:avatar, :first_name, :last_name)
  end

  def assign_user
    @user = User.find(params[:id])
  end

  def build_consolidations(project, consolidations)
    consolidations.each do |consolidation|
      @projects_quality[project] << consolidation.project_quality
      @projects_leadtime[project] << consolidation.lead_time_p80
      @projects_risk[project] << consolidation.operational_risk
      @projects_scope[project] << consolidation.project_scope
      @projects_value_per_demand[project] << consolidation.value_per_demand
      @projects_flow_pressure[project] << consolidation.flow_pressure
    end
  end

  def start_manager_charts_arrays(project)
    @projects_quality[project] = []
    @projects_leadtime[project] = []
    @projects_risk[project] = []
    @projects_scope[project] = []
    @projects_value_per_demand[project] = []
    @projects_flow_pressure[project] = []
  end

  def start_manager_charts_hashes
    @projects_quality = {}
    @projects_leadtime = {}
    @projects_risk = {}
    @projects_scope = {}
    @projects_value_per_demand = {}
    @projects_flow_pressure = {}
  end

  def running_projects(company)
    @running_projects ||= company.projects.running.order(:end_date)
  end
end
