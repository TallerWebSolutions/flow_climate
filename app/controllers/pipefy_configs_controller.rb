# frozen_string_literal: true

class PipefyConfigsController < AuthenticatedController
  before_action :assign_company

  def new
    @pipefy_config = PipefyConfig.new
  end

  def create
    @pipefy_config = PipefyConfig.new(pipefy_config_params.merge(company: @company))
    return redirect_to company_path(@company) if @pipefy_config.save
    render :new
  end

  private

  def pipefy_config_params
    params.require(:pipefy_config).permit(:project_id, :team_id, :pipe_id)
  end
end
