# frozen_string_literal: true

class TeamMembersController < AuthenticatedController
  before_action :user_gold_check

  before_action :assign_company
  before_action :assign_team_member, only: %i[edit update destroy show associate_user dissociate_user]

  def show
    render 'team_members/show'
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

  private

  def assign_team_members
    @team_members = @company.team_members.order(:name)
  end

  def assign_team_member
    @team_member = TeamMember.find(params[:id])
  end

  def team_member_params
    params.require(:team_member).permit(:name, :jira_account_user_email, :jira_account_id, :monthly_payment, :billable, :billable_type, :start_date, :end_date)
  end
end
