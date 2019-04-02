# frozen_string_literal: true

class FlowImpactsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_project

  def new
    @flow_impact = FlowImpact.new
    @demands_for_impact_form = @project.demands.in_wip
    render 'flow_impacts/new.js.erb'
  end

  def create
    @flow_impact = FlowImpact.new(flow_impact_params.merge(project: @project))
    @flow_impact.save
    @flow_impacts = @project.flow_impacts.order(:start_date)
    @demands_for_impact_form = @project.demands.in_wip
    render 'flow_impacts/create.js.erb'
  end

  def destroy
    @flow_impact = FlowImpact.find(params[:id])
    @flow_impact.destroy
    @flow_impacts = @project.flow_impacts.order(:start_date)
    render 'flow_impacts/destroy.js.erb'
  end

  def flow_impacts_tab
    @flow_impacts = @project.flow_impacts.order(:start_date)
    respond_to { |format| format.js { render file: 'flow_impacts/flow_impacts_tab.js.erb' } }
  end

  private

  def flow_impact_params
    params.require(:flow_impact).permit(:demand_id, :start_date, :end_date, :impact_description, :impact_type)
  end

  def assign_project
    @project = Project.find(params[:project_id])
  end
end
