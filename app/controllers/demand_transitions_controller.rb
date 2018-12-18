# frozen_string_literal: true

class DemandTransitionsController < AuthenticatedController
  before_action :user_plan_check

  before_action :assign_company
  before_action :assign_stage
  before_action :assign_demand_transition

  def destroy
    @demand_transition.destroy
    redirect_to company_stage_path(@company, @stage)
  end

  private

  def assign_stage
    @stage = Stage.find(params[:stage_id])
  end

  def assign_demand_transition
    @demand_transition = DemandTransition.find(params[:id])
  end
end
