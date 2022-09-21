# frozen_string_literal: true

class StageProjectConfigsController < AuthenticatedController
  before_action :user_gold_check

  before_action :assign_stage, except: %i[index destroy]
  before_action :assign_project, only: %i[index destroy]
  before_action :assign_stage_project_config, except: :index

  def edit; end

  def update
    @stage_project_config.update(stage_project_config_params.merge(max_seconds_in_stage: time_in_seconds_from_params,
                                                                   stage_percentage: not_null_parameter('stage_percentage'),
                                                                   pairing_percentage: not_null_parameter('pairing_percentage'),
                                                                   management_percentage: not_null_parameter('management_percentage')))

    recompute_manual_efforts_to_transitions_in_stage
    replicate_to_other_projects if params['replicate_to_projects'] == '1'

    redirect_to edit_company_stage_stage_project_config_path(@company, @stage, @stage_project_config)
  end

  def index
    @projects_to_copy_stages_from = (@company.projects - [@project]).sort_by(&:name)
    @stages_config_list = @project.stage_project_configs.joins(:stage).where('stages.order >= 0').order('stages.order, stages.name')
  end

  def destroy
    @stage_project_config.destroy

    flash[:notice] = I18n.t('general.destroy.success')

    redirect_to company_project_stage_project_configs_path(@company, @project)
  end

  private

  def time_in_seconds_from_params
    case params[:max_time_in_stage_period]
    when 'week'
      time_in_stage_param * 1.week
    when 'day'
      time_in_stage_param * 1.day
    else
      time_in_stage_param * 1.hour
    end
  end

  def time_in_stage_param
    params[:max_time_in_stage]&.to_i || 0
  end

  def recompute_manual_efforts_to_transitions_in_stage
    project = @stage_project_config.project
    stage = @stage_project_config.stage
    transitions = stage.demand_transitions.joins(demand: :project).where('demands.project_id' => project.id)
    demands = transitions.map(&:demand).flatten.uniq
    demands.map { |demand| DemandEffortService.instance.build_efforts_to_demand(demand) if !demand.manual_effort? || params['recompute_manual_efforts'] == '1' }
  end

  def replicate_to_other_projects
    @stage.projects.each do |project|
      stage_project_config = project.stage_project_configs.find_by(stage: @stage)
      stage_project_config.update(stage_project_config_params)
    end
  end

  def stage_project_config_params
    params.require(:stage_project_config).permit(:compute_effort, :stage_percentage, :management_percentage, :pairing_percentage, :max_seconds_in_stage)
  end

  def assign_stage
    @stage = Stage.find(params[:stage_id])
  end

  def assign_project
    @project = Project.find(params[:project_id])
  end

  def assign_stage_project_config
    @stage_project_config = StageProjectConfig.find(params[:id])
  end

  def not_null_parameter(param_name)
    return stage_project_config_params[param_name] if stage_project_config_params[param_name].present?

    0
  end
end
