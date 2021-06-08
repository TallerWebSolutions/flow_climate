# frozen_string_literal: true

class FlowImpactsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_project, except: %i[new_direct_link create_direct_link]
  before_action :assign_flow_impact, only: %i[destroy edit update show]

  def new
    @flow_impact = FlowImpact.new(project: @project, impact_date: Time.zone.now)
    @demands_for_impact_form = @project.demands.kept.in_flow(Time.zone.now).order(:external_id)
  end

  def create
    @flow_impact = FlowImpact.new(flow_impact_params.merge(project: @project, user: current_user))
    @demands_for_impact_form = @project.demands.kept.in_flow(Time.zone.now).order(:external_id)

    if @flow_impact.save
      flash[:notice] = I18n.t('flow_impacts.create.success')
      redirect_to company_project_flow_impacts_path(@company, @project)
    else
      flash[:error] = I18n.t('flow_impacts.create.error')
      render :new
    end
  end

  def destroy
    @flow_impact.destroy
    @flow_impacts = @project.flow_impacts.order(impact_date: :desc)
    respond_to { |format| format.js { render 'flow_impacts/destroy' } }
  end

  def new_direct_link
    @flow_impact = FlowImpact.new(impact_date: Time.zone.now)
    @projects_to_direct_link = @company.projects.running
    @demands_to_direct_link = []
  end

  def demands_to_project
    @demands_to_direct_link = @project.demands.kept.not_finished(Time.zone.now).order(:external_id)

    respond_to { |format| format.js { render 'flow_impacts/demands_to_project' } }
  end

  def create_direct_link
    @flow_impact = FlowImpact.new(flow_impact_direct_link_params.merge(user: current_user))
    if @flow_impact.save
      flash[:notice] = I18n.t('flow_impacts.create.success')
    else
      flash[:error] = @flow_impact.errors.full_messages.join(' | ')
    end

    redirect_to new_direct_link_company_flow_impacts_path(@company)
  end

  def index
    @flow_impacts = @project.flow_impacts.order(impact_date: :desc)
  end

  def edit
    @demands_for_impact_form = @flow_impact.project.demands.kept.order(:external_id)
  end

  def update
    @flow_impact.update(flow_impact_params)
    @demands_for_impact_form = @flow_impact.project.demands.kept.in_flow(Time.zone.now)

    redirect_to company_project_flow_impacts_path(@company, @project)
  end

  def show; end

  private

  def assign_flow_impact
    @flow_impact = FlowImpact.find(params[:id])
  end

  def flow_impact_params
    params.require(:flow_impact).permit(:demand_id, :impact_date, :impact_description, :impact_type, :impact_size)
  end

  def flow_impact_direct_link_params
    params.require(:flow_impact).permit(:project_id, :demand_id, :impact_date, :impact_description, :impact_type, :impact_size)
  end

  def assign_project
    @project = Project.find(params[:project_id])
  end
end
