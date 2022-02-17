# frozen_string_literal: true

class TeamMembersController < AuthenticatedController
  before_action :assign_company
  before_action :assign_team_member, only: %i[edit update destroy show associate_user dissociate_user pairings]

  def show
    assign_team_member_objects
    @member_demands = @team_member.demands
    build_demands_info(@member_demands)
    build_member_charts
    build_member_projects_charts

    render :show
  end

  def new
    @team_member = TeamMember.new(company: @company)

    assign_team_members

    respond_to { |format| format.js { render 'team_members/new' } }
  end

  def create
    @team_member = TeamMember.create(team_member_params.merge(company: @company))

    assign_team_members

    respond_to { |format| format.js { render 'team_members/create' } }
  end

  def edit
    assign_team_members

    respond_to { |format| format.js { render 'team_members/edit' } }
  end

  def update
    @team_member.update(team_member_params)

    assign_team_members

    respond_to { |format| format.js { render 'team_members/update' } }
  end

  def destroy
    @team_member.destroy

    respond_to { |format| format.js { render 'team_members/destroy' } }
  end

  def associate_user
    @team_member.update(user: current_user)

    respond_to { |format| format.js { render 'team_members/associate_dissociate_user' } }
  end

  def dissociate_user
    @team_member.update(user: nil)

    respond_to { |format| format.js { render 'team_members/associate_dissociate_user' } }
  end

  def search_team_members
    assign_team_members

    @team_members = case params['team_member_status']
                    when 'false'
                      @team_members.inactive
                    when 'true'
                      @team_members.active
                    else
                      @team_members
                    end

    respond_to { |format| format.js { render 'team_members/search_team_members' } }
  end

  def pairings
    operations_dashboards_cache
    pairings = @operations_dashboards.map(&:operations_dashboard_pairings).flatten.map(&:pair).uniq

    build_pairing_chart(pairings)
  end

  private

  def operations_dashboards_cache
    @operations_dashboards = Dashboards::OperationsDashboard.where(team_member: @team_member, last_data_in_month: true).order(:dashboard_date)
    @operations_dashboards = Dashboards::OperationsDashboard.where(team_member: @team_member).order(:dashboard_date) if @operations_dashboards.blank?
  end

  def build_pairing_chart(pairings)
    pairings_hash = build_pairings_hash(pairings)

    @pairing_chart = []

    pairings_hash.sort_by { |_key, value| value.last }.reverse.to_h.each do |key, value|
      @pairing_chart << { name: key, data: value }
    end
  end

  def build_pairings_hash(pairings)
    pairings_hash = {}

    pairings.each { |pair| pairings_hash[pair.name] = [] }

    @operations_dashboards.each do |operations_dashboard|
      pairings.each do |pair|
        pairings_hash[pair.name] << Dashboards::OperationsDashboardPairing.before_date(operations_dashboard.dashboard_date).for_team_member(pair, @team_member).last&.pair_times
      end
    end

    pairings_hash
  end

  def build_member_charts
    @member_effort_chart = []
    @member_pull_interval_average_chart = []

    operations_dashboards_cache

    @member_effort_chart << { name: @team_member.name, data: @operations_dashboards.map { |dashboard| dashboard.member_effort.to_f } }
    @member_pull_interval_average_chart << { name: @team_member.name, data: @operations_dashboards.map { |dashboard| dashboard.pull_interval.to_f } }
  end

  def assign_team_member_objects
    @member_teams = @team_member.teams.order(:name)
    @demand_blocks = @team_member.demand_blocks.order(block_time: :desc).first(5)
    @member_projects = @team_member.projects.active.order(end_date: :desc).last(5)
  end

  def assign_team_members
    @team_members = @company.team_members.order(:name)
  end

  def assign_team_member
    @team_member = @company.team_members.find(params[:id])
  end

  def team_member_params
    params.require(:team_member).permit(:name, :jira_account_user_email, :jira_account_id, :hours_per_month, :monthly_payment, :billable, :billable_type, :start_date, :end_date)
  end

  def build_member_projects_charts
    end_date = [@team_member.end_date, Time.zone.now].compact.min
    start_date = [@team_member.first_effort&.start_time_to_computation, @team_member.start_date, end_date - 12.months].compact.max

    @x_axis_hours_per_project = TimeService.instance.months_between_of(start_date, end_date)

    item_assignments_efforts = DemandEffort.joins(item_assignment: { membership: :team_member })
                                           .joins(:demand)
                                           .where('demand_efforts.effort_value > 0')
                                           .where(memberships: { team_member: @team_member })
                                           .where('start_time_to_computation BETWEEN :start_date AND :end_date', start_date: start_date, end_date: end_date)

    projects_in_efforts = item_assignments_efforts.map(&:demand).map(&:project).uniq

    @y_axis_hours_per_project = []
    projects_efforts = {}
    @x_axis_hours_per_project.each do |date|
      start_period = date.beginning_of_month
      end_period = date.end_of_month

      item_assignments_efforts_in_period = item_assignments_efforts.where('start_time_to_computation BETWEEN :start_date AND :end_date', start_date: start_period, end_date: end_period)
      projects_in_period = item_assignments_efforts.map(&:demand).map(&:project).uniq

      projects_in_period.each do |project_active|
        effort_value_sum = 0
        efforts_project_active = item_assignments_efforts_in_period.where(demand: { project: project_active })
        effort_value_sum = efforts_project_active.sum(&:effort_value) if efforts_project_active.present?

        project_with_effort = projects_efforts[project_active.name]
        if project_with_effort.present?
          project_with_effort << effort_value_sum.to_f
        else
          projects_efforts[project_active.name] = [effort_value_sum.to_f]
        end
      end

      projects_in_efforts_names = projects_in_efforts.map(&:name)
      projects_in_chart = projects_in_period.map(&:name)

      projects_not_present_in_period = projects_in_chart - projects_in_efforts_names

      projects_not_present_in_period.each do |project_name|
        if projects_efforts[project_name].present?
          projects_efforts[project_name] << 0
        else
          projects_efforts[project_name] = [0]
        end
      end
    end

    projects_efforts.each do |key, values|
      @y_axis_hours_per_project << { name: key, data: values }
    end
  end
end
