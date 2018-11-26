# frozen_string_literal: true

class StageProjectConfigsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_stage
  before_action :assign_stage_project_config

  def edit; end

  def update
    @stage_project_config.update(stage_project_config_params)
    recompute_manual_efforts_to_transitions_in_stage
    replicate_to_other_projects if params['replicate_to_projects'] == '1'
    redirect_to edit_company_stage_stage_project_config_path(@company, @stage, @stage_project_config)
  end

  private

  def recompute_manual_efforts_to_transitions_in_stage
    project = @stage_project_config.project
    stage = @stage_project_config.stage
    transitions = stage.demand_transitions.joins(demand: :project).where('demands.project_id = :project_id', project_id: project.id)
    demands = transitions.map(&:demand).flatten.uniq
    demands.map { |demand| demand.update_effort!(params['recompute_manual_efforts'] == '1') }
  end

  def replicate_to_other_projects
    @stage.projects.each do |project|
      stage_project_config = project.stage_project_configs.find_by(stage: @stage)
      stage_project_config.update(stage_project_config_params)
    end
  end

  def stage_project_config_params
    params.require(:stage_project_config).permit(:compute_effort, :stage_percentage, :management_percentage, :pairing_percentage)
  end

  def assign_stage
    @stage = Stage.find(params[:stage_id])
  end

  def assign_stage_project_config
    @stage_project_config = StageProjectConfig.find(params[:id])
  end
end
