# frozen_string_literal: true

class TeamMembersController < AuthenticatedController
  before_action :assign_company
  before_action :assign_team_member, only: %i[edit update destroy show associate_user dissociate_user pairings]

  def show
    assign_team_member_objects
    @member_demands = @team_member.demands
    build_demands_info(@member_demands)
    build_member_charts
    @team_chart_adapter = Highchart::TeamMemberAdapter.new(@team_member)

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
end
