# frozen_string_literal: true

class FlowImpactsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_project, except: %i[new_direct_link create_direct_link flow_impacts_tab edit update destroy]
  before_action :assign_flow_impact, only: %i[destroy edit update]

  def new
    @flow_impact = FlowImpact.new(project: @project)
    @demands_for_impact_form = @project.demands.in_wip.order(:external_id)
    assign_flow_impacts_list
    respond_to { |format| format.js { render 'flow_impacts/new' } }
  end

  def create
    @flow_impact = FlowImpact.new(flow_impact_params.merge(project: @project))
    @flow_impact.save
    assign_flow_impacts_list
    @demands_for_impact_form = @project.demands.in_wip
    respond_to { |format| format.js { render 'flow_impacts/create' } }
  end

  def destroy
    @flow_impact.destroy
    assign_flow_impacts_list
    respond_to { |format| format.js { render 'flow_impacts/destroy' } }
  end

  def flow_impacts_tab
    assign_flow_impacts_list
    respond_to { |format| format.js { render 'flow_impacts/flow_impacts_tab' } }
  end

  def new_direct_link
    @flow_impact = FlowImpact.new
    @projects_to_direct_link = @company.projects.running
    @demands_to_direct_link = []
  end

  def create_direct_link
    @flow_impact = FlowImpact.new(flow_impact_direct_link_params)
    if @flow_impact.save
      flash[:notice] = I18n.t('flow_impacts.create.success')
    else
      flash[:error] = @flow_impact.errors.full_messages.join(' | ')
    end

    redirect_to new_direct_link_company_flow_impacts_path(@company)
  end

  def demands_to_project
    project = @company.projects.find(params[:project_id])
    @demands_to_project = project.demands.in_wip.order(:external_id)

    respond_to { |format| format.js { render 'flow_impacts/demands_to_project' } }
  end

  def edit
    assign_flow_impacts_list
    @demands_for_impact_form = @flow_impact.project.demands.in_wip.order(:external_id)
    respond_to { |format| format.js { render 'flow_impacts/edit' } }
  end

  def update
    @flow_impact.update(flow_impact_params)
    assign_flow_impacts_list
    @demands_for_impact_form = @flow_impact.project.demands.in_wip
    respond_to { |format| format.js { render 'flow_impacts/update' } }
  end

  private

  def assign_flow_impacts_list
    @flow_impacts = []
    if params[:projects_ids].present?
      @flow_impacts = FlowImpact.where(project_id: params[:projects_ids].split(',')).order(:start_date)
    elsif @project.present?
      @flow_impacts = @project.flow_impacts.order(:start_date)
    end
  end

  def assign_flow_impact
    @flow_impact = FlowImpact.find(params[:id])
  end

  def flow_impact_params
    params.require(:flow_impact).permit(:demand_id, :start_date, :end_date, :impact_description, :impact_type)
  end

  def flow_impact_direct_link_params
    params.require(:flow_impact).permit(:project_id, :demand_id, :start_date, :end_date, :impact_description, :impact_type)
  end

  def assign_project
    @project = Project.find(params[:project_id])
  end
end
