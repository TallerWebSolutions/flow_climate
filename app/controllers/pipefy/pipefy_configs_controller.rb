# frozen_string_literal: true

module Pipefy
  class PipefyConfigsController < AuthenticatedController
    before_action :assign_company
    before_action :assign_pipefy_config, only: %i[destroy edit update]

    def new
      @pipefy_config = Pipefy::PipefyConfig.new
      assign_projects_to_select
    end

    def create
      @pipefy_config = Pipefy::PipefyConfig.new(pipefy_config_params.merge(company: @company))
      return redirect_to company_path(@company) if @pipefy_config.save
      assign_projects_to_select
      render :new
    end

    def destroy
      @pipefy_config.destroy
      redirect_to company_path(@company)
    end

    def edit
      assign_projects_to_select
    end

    def update
      @pipefy_config.update(pipefy_config_params.merge(company: @company))
      return redirect_to company_path(@company) if @pipefy_config.save
      assign_projects_to_select
      render :edit
    end

    private

    def pipefy_config_params
      params.require(:pipefy_pipefy_config).permit(:project_id, :team_id, :pipe_id)
    end

    def assign_pipefy_config
      @pipefy_config = Pipefy::PipefyConfig.find(params[:id])
    end

    def assign_projects_to_select
      @projects_to_select = @company.projects.no_pipefy_config.sort_by(&:full_name)
    end
  end
end
