# frozen_string_literal: true

class TeamMembersController < AuthenticatedController
  before_action :user_gold_check

  before_action :assign_company
  before_action :assign_team_member, only: %i[edit update destroy show associate_user dissociate_user]

  def show
    assign_team_member_objects
    @member_demands = @team_member.demands

    assign_chart_info

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

    if params['team_member_status'] == 'true'
      @team_members = @team_members.active
    elsif params['team_member_status'] == 'false'
      @team_members = @team_members.inactive
    end

    respond_to { |format| format.js { render 'team_members/search_team_members' } }
  end

  private

  def assign_chart_info
    @pairing_chart = {}
    @team_member.pairing_members.each { |name, qty| @pairing_chart[name] = qty }
    @array_of_dates = TimeService.instance.months_between_of(@member_demands.map(&:end_date).compact.min, Time.zone.today.end_of_month)

    @statistics_information = Flow::StatisticsFlowInformations.new(@member_demands)

    @array_of_dates.each { |analysed_date| @statistics_information.statistics_flow_behaviour(analysed_date) }
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
    params.require(:team_member).permit(:name, :jira_account_user_email, :jira_account_id, :monthly_payment, :billable, :billable_type, :start_date, :end_date)
  end
end
