# frozen_string_literal: true

class ProjectsController < ApplicationController
  before_action :assign_project, except: %i[show new create index search_projects_by_team status_report_dashboard]

  def index
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end

  def show
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end

  def new
    assign_customers
    @project = Project.new
  end

  def edit
    assign_customers
    assign_customer_projects
    assign_product_projects
  end

  def create
    @project = Project.new(project_params.merge(company: @company))
    return redirect_to company_projects_path(@company) if @project.save

    assign_customers
    render :new
  end

  def update
    check_change_in_deadline!
    @project.update(project_params)

    ProjectsRepository.instance.finish_project(@project, @project.end_date) if @project.valid? && @project.end_date <= Time.zone.today

    return redirect_to company_project_path(@company, @project) if @project.save

    assign_customers
    assign_customer_projects
    assign_product_projects

    render :edit
  end

  def destroy
    if @project.destroy
      flash[:notice] = I18n.t('project.destroy.success')
    else
      flash[:error] = "#{I18n.t('project.destroy.error')} - #{@project.errors.full_messages.join(' | ')}"
    end

    redirect_to company_projects_path(@company)
  end

  def search_projects_by_team
    @projects_by_team = @company.teams.find(params[:team_id]).projects.running.order(:name)
    respond_to { |format| format.js { render 'flow_events/search_projects_by_team' } }
  end

  def finish_project
    ProjectsRepository.instance.finish_project(@project, @project.end_date)
    flash[:notice] = I18n.t('projects.finish_project.success_message')
    redirect_to company_project_path(@company, @project)
  end

  def copy_stages_from
    @project_to_copy_stages_from = Project.find(params[:project_to_copy_stages_from])

    @project_to_copy_stages_from.stage_project_configs.each do |config|
      new_config = StageProjectConfig.find_or_initialize_by(stage: config.stage, project: @project)
      new_config.update(stage_percentage: config.stage_percentage, pairing_percentage: config.pairing_percentage, management_percentage: config.management_percentage,
                        max_seconds_in_stage: config.max_seconds_in_stage, compute_effort: config.compute_effort)
    end

    assign_project_stages

    redirect_to company_project_stage_project_configs_path(@company, @project)
  end

  def associate_customer
    customer = @company.customers.find(params[:customer_id])
    @project.add_customer(customer)
    assign_customer_projects
    respond_to { |format| format.js { render 'projects/associate_dissociate_customer' } }
  end

  def dissociate_customer
    customer = @company.customers.find(params[:customer_id])
    @project.remove_customer(customer)
    assign_customer_projects
    respond_to { |format| format.js { render 'projects/associate_dissociate_customer' } }
  end

  def associate_product
    product = @company.products.friendly.find(params[:product_id])
    @project.add_product(product)
    assign_product_projects
    respond_to { |format| format.js { render 'projects/associate_dissociate_product' } }
  end

  def dissociate_product
    product = @company.products.friendly.find(params[:product_id])
    @project.remove_product(product)
    assign_product_projects
    respond_to { |format| format.js { render 'projects/associate_dissociate_product' } }
  end

  def risk_drill_down
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end

  def status_report_dashboard
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end

  def lead_time_dashboard
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end

  def statistics_tab
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end

  def financial_report
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end

  private

  def check_change_in_deadline!
    return if project_params[:end_date].blank? || @project.end_date == Date.parse(project_params[:end_date])

    ProjectChangeDeadlineHistory.create!(user: Current.user, project: @project, previous_date: @project.end_date, new_date: project_params[:end_date])
  end

  def project_params
    params.require(:project).permit(:name, :nickname, :status, :project_type, :start_date, :end_date, :value, :qty_hours, :hour_value, :initial_scope, :percentage_effort_to_bugs, :team_id, :max_work_in_progress)
  end

  def assign_project_stages
    @stages_list = @project.reload.stages.order(:order, :name)
  end

  def assign_project
    @project = @company.projects.includes(:team).find(params[:id])
  end

  def assign_customer_projects
    @project_customers = @project.customers.order(:name)
    @not_associated_customers = @company.customers - @project_customers
  end

  def assign_product_projects
    @project_products = @project.products.order(:name)
    @not_associated_products = @company.products - @project_products
  end
end
