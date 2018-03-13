# frozen_string_literal: true

class PipefyTeamConfigsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_team
  before_action :assign_pipefy_team_config

  def edit; end

  def update
    @pipefy_team_config.update(pipefy_team_config_params.merge(team: @team))
    return redirect_to company_team_path(@company, @team) if @pipefy_team_config.save
    render :edit
  end

  private

  def assign_team
    @team = Team.find(params[:team_id])
  end

  def assign_pipefy_team_config
    @pipefy_team_config = PipefyTeamConfig.find(params[:id])
  end

  def pipefy_team_config_params
    params.require(:pipefy_team_config).permit(:member_type, :username, :integration_id)
  end
end
