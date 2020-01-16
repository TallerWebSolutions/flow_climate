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
    @companies_list = @user.companies.order(:name)
    assign_team_member_dependencies
    assign_user_dependencies
    assign_stats_info
  end

  def edit
    @companies_list = @user.companies.order(:name)
  end

  def update
    return redirect_to user_path(@user) if @user.update(user_params)

    @companies_list = @user.companies.order(:name)
    assign_user_dependencies
    render :show
  end

  def companies
    @companies = @user.companies.order(:name)

    render 'companies/index'
  end

  private

  def assign_team_member_dependencies
    @pairing_chart = {}
    @teams = []
    return if @user.team_member.blank?

    @user.team_member.pairing_members.each { |name, qty| @pairing_chart[name] = qty }
    @member_teams = @user.team_member.teams.order(:name)
    @demand_blocks = @user.team_member.demand_blocks.order(block_time: :desc).first(5)
    @member_projects = @user.team_member.projects.active.order(end_date: :desc).last(5)
  end

  def assign_user_dependencies
    @user_plans = @user.user_plans.order(finish_at: :desc)
  end

  def assign_stats_info
    user_demands = @user.demands

    @array_of_dates = TimeService.instance.months_between_of(user_demands.map(&:end_date).compact.min, Time.zone.today.end_of_month)

    @statistics_informations = Flow::StatisticsFlowInformations.new(user_demands)

    @array_of_dates.each { |analysed_date| @statistics_informations.statistics_flow_behaviour(analysed_date) }
  end

  def user_params
    params.require(:user).permit(:avatar, :first_name, :last_name)
  end

  def assign_user
    @user = User.find(params[:id])
  end
end
