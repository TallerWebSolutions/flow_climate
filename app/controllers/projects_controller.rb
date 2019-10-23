# frozen_string_literal: true

class ProjectsController < AuthenticatedController
  before_action :user_gold_check

  before_action :assign_company
  before_action :assign_project, except: %i[new create index search_projects]

  def show
    assign_project_stages
    assign_customer_projects
    assign_product_projects
    assign_projects_to_copy_stages_from
    assign_demands_ids

    @ordered_project_risk_alerts = @project.project_risk_alerts.order(created_at: :desc)
    @project_change_deadline_histories = @project.project_change_deadline_histories.includes(:user)
    @inconsistent_demands = @project.demands.dates_inconsistent_to_project(@project)
    @unscored_demands = @project.demands.unscored_demands.order(external_id: :asc)
  end

  def index
    @projects = @company.projects.includes(:team).order(end_date: :desc)

    @projects_summary = ProjectsSummaryData.new(@projects)
  end

  def new
    assign_customers
    @project = Project.new
  end

  def create
    @project = Project.new(project_params.merge(company: @company))
    return redirect_to company_projects_path(@company) if @project.save

    assign_customers
    render :new
  end

  def edit
    assign_customers
  end

  def update
    check_change_in_deadline!
    @project.update(project_params)

    return redirect_to company_project_path(@company, @project) if @project.save

    assign_customers
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

  def finish_project
    ProjectsRepository.instance.finish_project!(@project)
    flash[:notice] = I18n.t('projects.finish_project.success_message')
    redirect_to company_project_path(@company, @project)
  end

  def statistics
    respond_to { |format| format.js { render 'projects/project_statistics' } }
  end

  def copy_stages_from
    @project_to_copy_stages_from = Project.find(params[:project_to_copy_stages_from])
    @project.update(stages: (@project.stages + @project_to_copy_stages_from.stages) - (@project.stages & @project_to_copy_stages_from.stages))
    assign_project_stages

    respond_to { |format| format.js { render 'stages/update_stages_table' } }
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
    product = @company.products.find(params[:product_id])
    @project.add_product(product)
    assign_product_projects
    respond_to { |format| format.js { render 'projects/associate_dissociate_product' } }
  end

  def dissociate_product
    product = @company.products.find(params[:product_id])
    @project.remove_product(product)
    assign_product_projects
    respond_to { |format| format.js { render 'projects/associate_dissociate_product' } }
  end

  def risk_drill_down
    @project_consolidations = @project.project_consolidations.order(:consolidation_date)
    respond_to { |format| format.js { render 'projects/risk_drill_down' } }
  end

  def closing_dashboard
    @project_summary = ProjectsSummaryData.new([@project])

    respond_to { |format| format.js { render 'projects/closing_info' } }
  end

  def status_report_dashboard
    @project_summary = ProjectsSummaryData.new([@project])
    x_axis = TimeService.instance.weeks_between_of(@project.start_date.beginning_of_week, @project.end_date.end_of_week)
    @work_item_flow_information = Flow::WorkItemFlowInformations.new(x_axis, @project.start_date, Time.zone.now.end_of_week, @project.demands, @project.initial_scope)

    respond_to { |format| format.js { render 'projects/status_report_dashboard' } }
  end

  def lead_time_dashboard
    @project_consolidations = @project.project_consolidations.order(:consolidation_date)

    respond_to { |format| format.js { render 'projects/lead_time_dashboard' } }
  end

  def search_projects
    @target_name = params[:target_name]

    @projects = build_projects_search(params[:start_date], params[:end_date], params[:project_status])
    @projects = @projects.order(end_date: :desc)

    @projects_summary = ProjectsSummaryData.new(@projects)

    respond_to { |format| format.js { render 'projects/search_projects' } }
  end

  private

  def build_projects_search(start_date, end_date, project_status)
    @projects = Project.where(id: params[:projects_ids].split(','))
    @projects = @projects.where(status: project_status) if project_status.present?
    @projects = @projects.where('start_date >= :start_date', start_date: start_date) if params[:start_date].present?
    @projects = @projects.where('end_date <= :end_date', end_date: end_date) if params[:end_date].present?
    @projects
  end

  def assign_demands_ids
    @demands_ids = @project.demands.opened_before_date(Time.zone.now).map(&:id)
  end

  def assign_projects_to_copy_stages_from
    @projects_to_copy_stages_from = (@company.projects - [@project]).sort_by(&:name)
  end

  def assign_project_stages
    @stages_list = @project.reload.stages.order(:order, :name)
  end

  def project_params
    params.require(:project).permit(:name, :nickname, :status, :project_type, :start_date, :end_date, :value, :qty_hours, :hour_value, :initial_scope, :percentage_effort_to_bugs, :team_id, :max_work_in_progress)
  end

  def assign_project
    @project = Project.includes(:team).find(params[:id])
  end

  def check_change_in_deadline!
    return if project_params[:end_date].blank? || @project.end_date == Date.parse(project_params[:end_date])

    ProjectChangeDeadlineHistory.create!(user: current_user, project: @project, previous_date: @project.end_date, new_date: project_params[:end_date])
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
