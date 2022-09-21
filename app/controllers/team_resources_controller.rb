# frozen_string_literal: true

class TeamResourcesController < AuthenticatedController
  before_action :assign_team_resource, only: :destroy

  def new
    @team_resource = TeamResource.new(company: @company)

    respond_to { |format| format.js { render 'team_resources/new' } }
  end

  def create
    @team_resource = TeamResource.create(team_resource_params.merge(company: @company))
    @team_resources = @company.team_resources.order(:resource_name)

    respond_to { |format| format.js { render 'team_resources/create' } }
  end

  def destroy
    @team_resource.destroy
    respond_to { |format| format.js { render 'team_resources/destroy' } }
  end

  private

  def assign_team_resource
    @team_resource = @company.team_resources.find(params[:id])
  end

  def team_resource_params
    params.require(:team_resource).permit(:resource_type, :resource_name)
  end
end
