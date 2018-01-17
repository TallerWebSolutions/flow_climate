# frozen_string_literal: true

class ProjectsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_project, only: %i[show edit update]

  def show
    @project_results = @project.project_results.order(result_date: :desc)
    @total_hours_upstream = @project_results.sum(&:qty_hours_upstream)
    @total_hours_downstream = @project_results.sum(&:qty_hours_downstream)
    @total_hours = @project_results.sum(&:project_delivered_hours)
    @total_throughput = @project_results.sum(&:throughput)
    @total_bugs_opened = @project_results.sum(&:qty_bugs_opened)
    @total_bugs_closed = @project_results.sum(&:qty_bugs_closed)
    @total_hours_bug = @project_results.sum(&:qty_hours_bug)
    @avg_leadtime = @project_results.average(:leadtime)
  end

  def index
    mount_projects_list
    @total_hours = @projects.sum(&:qty_hours)
    @total_consumed_hours = @projects.sum(&:consumed_hours)
    @average_hour_value = @projects.average(:hour_value)
    @total_value = @projects.sum(&:value)
    @total_days = @projects.sum(&:total_days)
    @total_remaining_days = @projects.sum(&:remaining_days)
  end

  def new
    @project = Project.new
  end

  def create
    assign_customer
    assign_product
    @project = Project.new(project_params.merge(customer: @customer, product: @product))
    return redirect_to company_projects_path(@company) if @project.save
    render :new
  end

  def edit; end

  def update
    assign_customer
    assign_product
    @project.update(project_params.merge(customer: @customer, product: @product))
    return redirect_to company_projects_path(@company) if @project.save
    render :edit
  end

  private

  def assign_product
    @product = Product.find_by(id: project_params[:product_id])
  end

  def assign_customer
    @customer = Customer.find_by(id: project_params[:customer_id])
  end

  def project_params
    params.require(:project).permit(:customer_id, :product_id, :name, :status, :project_type, :start_date, :end_date, :value, :qty_hours, :hour_value, :initial_scope)
  end

  def mount_projects_list
    @projects = Project.joins(product: :customer).where('customers.company_id = ?', @company.id)
    @projects = @projects.where(status: params[:status_filter]) if params[:status_filter].present?
    @projects = @projects.order(end_date: :desc)
  end

  def assign_company
    @company = Company.find(params[:company_id])
    not_found unless current_user.companies.include?(@company)
  end

  def assign_project
    @project = Project.find(params[:id])
  end
end
