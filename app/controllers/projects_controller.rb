# frozen_string_literal: true

class ProjectsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_project, only: %i[show edit update]

  def show
    project_results = @project.project_results.order(result_date: :desc)
    @project_results_summary = ProjectResultsSummaryObject.new(@company, @project, project_results)
  end

  def index
    mount_projects_list
    @projects_summary = ProjectsSummaryObject.new(@projects)
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
    @projects = Project.joins(:customer).where('customers.company_id = ?', @company.id)
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
