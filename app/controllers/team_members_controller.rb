# frozen_string_literal: true

class TeamMembersController < AuthenticatedController
  before_action :user_gold_check

  before_action :assign_company
  before_action :assign_team_member, only: %i[edit update destroy]

  def new
    @team_member = TeamMember.new(company: @company)

    assign_team_members

    respond_to { |format| format.js { render 'team_members/new.js.erb' } }
  end

  def create
    @team_member = TeamMember.create(team_member_params.merge(company: @company))

    assign_team_members

    respond_to { |format| format.js { render 'team_members/create.js.erb' } }
  end

  def edit
    assign_team_members

    respond_to { |format| format.js { render 'team_members/edit.js.erb' } }
  end

  def update
    @team_member.update(team_member_params)

    assign_team_members

    respond_to { |format| format.js { render 'team_members/update.js.erb' } }
  end

  def destroy
    @team_member.destroy

    respond_to { |format| format.js { render 'team_members/destroy.js.erb' } }
  end

  private

  def assign_team_members
    @team_members = @company.team_members.order(:name)
  end

  def assign_team_member
    @team_member = TeamMember.find(params[:id])
  end

  def team_member_params
    params.require(:team_member).permit(:name, :jira_account_user_email, :jira_account_id, :monthly_payment, :hours_per_month, :billable, :billable_type, :start_date, :end_date)
  end
end
