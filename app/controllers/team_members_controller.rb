# frozen_string_literal: true

class TeamMembersController < AuthenticatedController
  before_action :assign_company
  before_action :assign_team
  before_action :assign_team_member, only: %i[edit update activate deactivate]

  def new
    @team_member = TeamMember.new(team: @team)
  end

  def create
    @team_member = TeamMember.new(team_member_params.merge(team: @team))
    return redirect_to company_team_path(@company, @team) if @team_member.save
    render :new
  end

  def edit; end

  def update
    @team_member.update(team_member_params.merge(team: @team))
    return redirect_to company_team_path(@company, @team) if @team_member.save
    render :edit
  end

  def activate
    @team_member.update(active: true)
    redirect_to company_team_path(@company, @team)
  end

  def deactivate
    @team_member.update(active: false)
    redirect_to company_team_path(@company, @team)
  end

  private

  def assign_team
    @team = Team.find(params[:team_id])
  end

  def assign_team_member
    @team_member = TeamMember.find(params[:id])
  end

  def team_member_params
    params.require(:team_member).permit(:name, :monthly_payment, :hours_per_month, :billable, :active, :billable_type)
  end
end
