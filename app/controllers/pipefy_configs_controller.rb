# frozen_string_literal: true

class PipefyConfigsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_pipefy_config, only: [:destroy]

  def new
    @pipefy_config = PipefyConfig.new
  end

  def create
    @pipefy_config = PipefyConfig.new(pipefy_config_params.merge(company: @company))
    return redirect_to company_path(@company) if @pipefy_config.save
    render :new
  end

  def destroy
    @pipefy_config.destroy
    redirect_to company_path(@company)
  end

  private

  def pipefy_config_params
    params.require(:pipefy_config).permit(:project_id, :team_id, :pipe_id)
  end

  def assign_pipefy_config
    @pipefy_config = PipefyConfig.find(params[:id])
  end
end
