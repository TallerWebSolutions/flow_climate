# frozen_string_literal: true

class TeamMembersController < AuthenticatedController
  before_action :assign_company
  before_action :assign_team

  def new
    @team_member = TeamMember.new(team: @team)
  end

  def create
    @team_member = TeamMember.new(team_member_params.merge(team: @team))
    return redirect_to company_team_path(@company, @team) if @team_member.save
    render :new
  end

  private

  def assign_team
    @team = Team.find(params[:team_id])
  end

  def team_member_params
    params.require(:team_member).permit(:name, :monthly_payment, :hours_per_month, :billable, :active, :billable_type)
  end
end
