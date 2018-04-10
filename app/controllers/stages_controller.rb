# frozen_string_literal: true

class StagesController < AuthenticatedController
  before_action :assign_company
  before_action :assign_stage, only: %i[edit update destroy show]

  def new
    @stage = Stage.new
  end

  def create
    @stage = Stage.new(stages_params.merge(company: @company))
    return redirect_to company_path(@company) if @stage.save
    render :new
  end

  def edit; end

  def update
    return redirect_to company_path(@company) if @stage.update(stages_params)
    render :edit
  end

  def destroy
    return redirect_to company_path(@company) if @stage.destroy
    redirect_to(company_path(@company), flash: { error: @stage.errors.full_messages.join(',') })
  end

  def show
    @not_associated_projects = (@company.projects - @stage.projects).sort_by(&:full_name)
    @stage_projects = @stage.projects.sort_by(&:full_name)
    @transitions_in_stage = @stage.demand_transitions
  end

  private

  def stages_params
    params.require(:stage).permit(:integration_id, :name, :stage_type, :stage_stream, :commitment_point, :end_point, :queue, :compute_effort, :percentage_effort)
  end

  def assign_stage
    @stage = @company.stages.find(params[:id])
  end
end
