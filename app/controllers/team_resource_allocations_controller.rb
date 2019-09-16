# frozen_string_literal: true

class TeamResourceAllocationsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_team

  before_action :assign_team_resource_allocation, only: :destroy

  def new
    @team_resource_allocation = TeamResourceAllocation.new(team: @team)
    @team_resources = @company.team_resources.order(:resource_name)

    respond_to { |format| format.js { render 'team_resource_allocations/new' } }
  end

  def create
    @team_resource_allocation = TeamResourceAllocation.create(team_resource_params.merge(team: @team))
    @team_resources = @company.team_resources.order(:resource_name)
    @team_resource_allocations = @team.team_resource_allocations.order(:start_date)

    respond_to { |format| format.js { render 'team_resource_allocations/create' } }
  end

  def destroy
    @team_resource_allocation.destroy
    @team_resource_allocations = @team.team_resource_allocations.order(:start_date)
    respond_to { |format| format.js { render 'team_resource_allocations/destroy' } }
  end

  private

  def assign_team
    @team = @company.teams.find(params[:team_id])
  end

  def assign_team_resource_allocation
    @team_resource_allocation = @team.team_resource_allocations.find(params[:id])
  end

  def team_resource_params
    params.require(:team_resource_allocation).permit(:team_resource_id, :start_date, :end_date, :monthly_payment)
  end
end
