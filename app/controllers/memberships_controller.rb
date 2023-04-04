# frozen_string_literal: true

class MembershipsController < AuthenticatedController
  before_action :user_gold_check

  before_action :assign_team
  before_action :assign_membership, only: %i[edit update destroy]

  def index
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end

  def new
    @membership = Membership.new(team: @team)

    assign_memberships_list
    assign_team_members_list

    respond_to { |format| format.js { render 'memberships/new' } }
  end

  def edit
    assign_memberships_list
    assign_team_members_list

    respond_to { |format| format.js { render 'memberships/edit' } }
  end

  def create
    @membership = Membership.create(membership_params.merge(team: @team))

    assign_memberships_list
    assign_team_members_list

    respond_to { |format| format.js { render 'memberships/create' } }
  end

  def update
    @membership.update(membership_params)

    assign_memberships_list
    assign_team_members_list

    respond_to { |format| format.js { render 'memberships/update' } }
  end

  def destroy
    @membership.destroy

    respond_to { |format| format.js { render 'memberships/destroy' } }
  end

  def search_memberships
    assign_memberships_list

    case params['membership_status']
    when 'true'
      @memberships = @memberships.active
    when 'false'
      @memberships = @memberships.inactive
    end

    respond_to { |format| format.js { render 'memberships/search_memberships' } }
  end

  private

  def assign_memberships_list
    @memberships = @team.memberships.includes('team_member').order('team_members.name, memberships.start_date')
  end

  def assign_team_members_list
    @team_members = @company.team_members.order(:name)
  end

  def assign_team
    @team = @company.teams.find(params[:team_id])
  end

  def assign_membership
    @membership = Membership.find(params[:id])
  end

  def membership_params
    params.require(:membership).permit(:member_role, :team_member_id, :hours_per_month, :start_date, :end_date)
  end
end
