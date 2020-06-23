# frozen_string_literal: true

class UsersController < AuthenticatedController
  before_action :check_admin, only: %i[toggle_admin admin_dashboard]
  before_action :assign_user, only: %i[toggle_admin show edit update companies user_dashboard_company_tab]

  def admin_dashboard
    @users_list = User.all.order(%i[last_name first_name])
    @companies_list = Company.all.order(:name)
  end

  def activate_email_notifications
    current_user.update(email_notifications: true)
    respond_to { |format| format.js { render 'users/reload_notifications.js.erb' } }
  end

  def deactivate_email_notifications
    current_user.update(email_notifications: false)
    respond_to { |format| format.js { render 'users/reload_notifications.js.erb' } }
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

  def user_dashboard_company_tab
    assign_company

    assign_charts_objects(@company)
    assign_team_member_dependencies
    assign_user_dependencies
    assign_stats_info

    respond_to { |format| format.js { render 'users/user_dashboard_company_tab.js.erb' } }
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

    assign_charts_objects(@company) if @company.present?

    assign_team_member_dependencies
    assign_user_dependencies
    assign_stats_info
  end

  def assign_charts_objects(company)
    assign_active_projects_quality_info(company)
    assign_active_projects_lead_time_info(company)
    assign_active_projects_risk_info(company)
    assign_active_projects_scope_info(company)
    assign_active_projects_value_per_demand_info(company)
    assign_active_projects_flow_pressure_info(company)
  end

  def assign_team_member_dependencies
    @pairing_chart = {}
    @teams = []
    return if @user.team_member.blank?

    build_pairing_chart

    @member_teams = @user.team_member.teams.order(:name)
    @demand_blocks = @user.team_member.demand_blocks.order(block_time: :desc).first(5)
    @member_projects = @user.team_member.projects.active.order(end_date: :desc).last(5)

    build_member_effort_chart(@user.team_member)
  end

  def build_member_effort_chart(team_member)
    @member_effort_chart = []

    team_member.memberships.active.each do |membership|
      membership_service = Flow::MembershipFlowInformation.new(membership)

      @member_effort_chart << { name: membership.team.name, data: membership_service.compute_developer_effort }
    end
  end

  def build_pairing_chart
    @user.team_member.pairing_members.each { |name, qty| @pairing_chart[name] = qty }
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

  # TODO: the following methods should be in a service

  def assign_active_projects_quality_info(company)
    @projects_quality = {}
    running_projects(company).each { |project| @projects_quality[project] = project.quality * 100 }
  end

  def assign_active_projects_lead_time_info(company)
    @projects_leadtime = {}
    running_projects(company).each { |project| @projects_leadtime[project] = (project.general_leadtime / 1.day).round(3) }
  end

  def assign_active_projects_risk_info(company)
    @projects_risk = {}
    running_projects(company).each { |project| @projects_risk[project] = project.current_risk_to_deadline * 100 }
  end

  def assign_active_projects_scope_info(company)
    @projects_scope = {}
    running_projects(company).each { |project| @projects_scope[project] = project.remaining_backlog }
  end

  def assign_active_projects_value_per_demand_info(company)
    @projects_value_per_demand = {}
    running_projects(company).each { |project| @projects_value_per_demand[project] = project.value_per_demand }
  end

  def assign_active_projects_flow_pressure_info(company)
    @projects_flow_pressure = {}
    running_projects(company).each { |project| @projects_flow_pressure[project] = project.flow_pressure.to_f }
  end

  def running_projects(company)
    @running_projects ||= company.projects.running
  end
end
