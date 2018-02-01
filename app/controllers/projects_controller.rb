# frozen_string_literal: true

class ProjectsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_project, only: %i[show edit update]

  def show
    @ordered_project_results = @project.project_results.order(:result_date)
    @report_data = ReportData.new(Project.where(id: @project.id))
    @hours_per_demand_data = [{ name: I18n.t('projects.charts.hours_per_demand.ylabel'), data: @report_data.hours_per_demand_chart_data_for_week(@ordered_project_results) }]
    @ordered_project_risk_alerts = @project.project_risk_alerts.order(created_at: :desc)
  end

  def index
    mount_projects_list
    @projects_summary = ProjectsSummaryObject.new(@projects)
  end

  def new
    @project = Project.new
    @products = []
  end

  def create
    assign_customer
    assign_product
    @project = Project.new(project_params.merge(customer: @customer, product: @product))
    return redirect_to company_projects_path(@company) if @project.save
    assign_products_list
    render :new
  end

  def edit
    assign_products_list
  end

  def update
    assign_customer
    assign_product
    @project.update(project_params.merge(customer: @customer, product: @product))
    return redirect_to company_projects_path(@company) if @project.save
    assign_products_list
    render :edit
  end

  def product_options_for_customer
    render_products_for_customer('projects/product_options.js.erb', params[:customer_id])
  end

  private

  def assign_products_list
    @products = @project.customer.products.order(:name)
  end

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
