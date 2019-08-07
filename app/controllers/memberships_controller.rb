# frozen_string_literal: true

class MembershipsController < AuthenticatedController
  before_action :user_gold_check

  before_action :assign_company
  before_action :assign_team
  before_action :assign_membership, only: %i[edit update destroy]

  def new
    @membership = Membership.new(team: @team)

    assign_memberships_list
    assign_team_members_list

    respond_to { |format| format.js { render 'memberships/new.js.erb' } }
  end

  def create
    @membership = Membership.create(membership_params.merge(team: @team))

    assign_memberships_list
    assign_team_members_list

    respond_to { |format| format.js { render 'memberships/create.js.erb' } }
  end

  def edit
    assign_memberships_list
    assign_team_members_list

    respond_to { |format| format.js { render 'memberships/edit.js.erb' } }
  end

  def update
    @membership.update(membership_params)

    assign_memberships_list
    assign_team_members_list

    respond_to { |format| format.js { render 'memberships/update.js.erb' } }
  end

  def destroy
    @membership.destroy

    respond_to { |format| format.js { render 'memberships/destroy.js.erb' } }
  end

  private

  def assign_memberships_list
    @memberships = @team.memberships.sort_by(&:team_member_name)
  end

  def assign_team_members_list
    @team_members = @company.team_members.order(:name) - @team.memberships.map(&:team_member)
  end

  def assign_team
    @team = @company.teams.find(params[:team_id])
  end

  def assign_membership
    @membership = Membership.find(params[:id])
  end

  def membership_params
    params.require(:membership).permit(:member_role, :team_member_id)
  end
end
