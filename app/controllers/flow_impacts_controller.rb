# frozen_string_literal: true

class FlowImpactsController < AuthenticatedController
  before_action :assign_company

  def new
    @flow_impact = FlowImpact.new
  end

  def create
    @flow_impact = FlowImpact.new(flow_impact_params)
    @flow_impact.save
    render 'flow_impacts/create.js.erb'
  end

  def destroy
    @flow_impact = FlowImpact.find(params[:id])
    @flow_impact.destroy
    render 'flow_impacts/destroy.js.erb'
  end

  private

  def flow_impact_params
    params.require(:flow_impact).permit(:project_id, :start_date, :end_date, :impact_description, :impact_type)
  end
end
