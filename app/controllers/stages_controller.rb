# frozen_string_literal: true

class StagesController < AuthenticatedController
  before_action :assign_company

  def new
    @stage = Stage.new
  end

  def create
    @stage = Stage.new(stages_params.merge(company: @company))
    return redirect_to company_path(@company) if @stage.save
    render :new
  end

  private

  def stages_params
    params.require(:stage).permit(:integration_id, :name, :stage_type, :stage_stream, :commitment_point, :end_point, :queue, :compute_effort, :percentage_effort)
  end
end
