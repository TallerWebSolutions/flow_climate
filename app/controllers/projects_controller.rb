# frozen_string_literal: true

class ProjectsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_customer, only: %i[create update]
  before_action :assign_product, only: %i[create update]
  before_action :assign_project, only: %i[show edit update destroy synchronize_pipefy finish_project delivered_demands_csv search_demands_by_flow_status]

  def show
    @ordered_project_results = @project.project_results.order(:result_date)
    projects = Project.where(id: @project.id)
    @report_data = Highchart::OperationalChartsAdapter.new(projects, 'all')
    @status_report_data = Highchart::StatusReportChartsAdapter.new(projects, 'all')
    @ordered_project_risk_alerts = @project.project_risk_alerts.order(created_at: :desc)
    @demands = DemandsRepository.instance.demands_per_projects(projects)
    assign_grouped_demands_informations(@demands)
    @project_change_deadline_histories = @project.project_change_deadline_histories
    @montecarlo_dates = @status_report_data.monte_carlo_data
  end

  def index
    @projects = add_status_filter(Project.joins(:customer).where('customers.company_id = ?', @company.id)).order(end_date: :desc)
    @projects_summary = ProjectsSummaryData.new(@projects)
  end

  def new
    @project = Project.new
    @products = []
  end

  def create
    @project = Project.new(project_params.merge(customer: @customer, product: @product))
    return redirect_to company_projects_path(@company) if @project.save
    assign_products_list
    render :new
  end

  def edit
    assign_products_list
  end

  def update
    check_change_in_deadline!
    previous_scope_value = @project.initial_scope
    @project.update(project_params.merge(customer: @customer, product: @product))
    check_change_in_initial_scope!(previous_scope_value)
    return redirect_to company_project_path(@company, @project) if @project.save
    assign_products_list
    render :edit
  end

  def product_options_for_customer
    render_products_for_customer('projects/product_options.js.erb', params[:customer_id])
  end

  def search_for_projects
    @projects = ProjectsRepository.instance.add_query_to_projects_in_status(@company.projects.joins(:customer), params[:status_filter])
    @projects_summary = ProjectsSummaryData.new(@projects)
    respond_to { |format| format.js { render file: 'projects/projects_search.js.erb' } }
  end

  def destroy
    @project.destroy
    redirect_to company_projects_path(@company)
  end

  def synchronize_pipefy
    Pipefy::ProcessPipefyProjectJob.perform_later(@project)
    flash[:notice] = t('general.enqueued')
    redirect_to company_project_path(@company, @project)
  end

  def finish_project
    ProjectsRepository.instance.finish_project!(@project)
    flash[:notice] = t('projects.finish_project.success_message')
    redirect_to company_project_path(@company, @project)
  end

  def delivered_demands_csv
    @project_delivered_demands = @project.demands.kept.finished.order(end_date: :desc)
    attributes = %w[id demand_id demand_type class_of_service effort_downstream effort_upstream created_date commitment_date end_date]
    demands_csv = CSV.generate(headers: true) do |csv|
      csv << attributes
      @project_delivered_demands.each { |demand| csv << attributes.map { |attr| demand.send(attr) } }
    end
    respond_to { |format| format.csv { send_data demands_csv, filename: "demands-#{Time.zone.now}.csv" } }
  end

  def search_demands_by_flow_status
    projects = Project.where(id: @project.id)
    demands_for_query_ids = build_demands_query(projects)
    @demands = Demand.where(id: demands_for_query_ids.map(&:id))
    assign_grouped_demands_informations(@demands)
    respond_to { |format| format.js { render file: 'demands/search_demands_by_flow_status.js.erb' } }
  end

  private

  def assign_products_list
    @products = (@customer || @project.customer)&.products&.order(:name) || []
  end

  def assign_product
    @product = Product.find_by(id: project_params[:product_id])
  end

  def assign_customer
    @customer = Customer.find_by(id: project_params[:customer_id])
  end

  def project_params
    params.require(:project).permit(:customer_id, :product_id, :name, :nickname, :status, :project_type, :start_date, :end_date, :value, :qty_hours, :hour_value, :initial_scope, :percentage_effort_to_bugs)
  end

  def assign_company
    @company = Company.find(params[:company_id])
    not_found unless current_user.companies.include?(@company)
  end

  def assign_project
    @project = Project.find(params[:id])
  end

  def add_status_filter(projects)
    return projects if params[:status_filter].blank? || projects.blank?
    projects.where(status: params[:status_filter])
  end

  def check_change_in_deadline!
    return if project_params[:end_date].blank? || @project.end_date == Date.parse(project_params[:end_date])
    ProjectChangeDeadlineHistory.create!(user: current_user, project: @project, previous_date: @project.end_date, new_date: project_params[:end_date])
  end

  def check_change_in_initial_scope!(previous_scope_param)
    return if project_params[:initial_scope].blank? || previous_scope_param == project_params[:initial_scope].to_i
    @project.project_results.order(:result_date).map(&:compute_flow_metrics!)
  end

  def build_demands_query(projects)
    return DemandsRepository.instance.not_started_demands(projects) if params[:not_started] == 'true'
    return DemandsRepository.instance.committed_demands(projects) if params[:wip] == 'true'
    return DemandsRepository.instance.demands_finished_per_projects(projects) if params[:delivered] == 'true'
    DemandsRepository.instance.demands_per_projects(projects)
  end

  def assign_grouped_demands_informations(demands)
    @grouped_delivered_demands = demands.grouped_end_date_by_month if params[:grouped_by_month] == 'true'
    @grouped_customer_demands = demands.grouped_by_customer if params[:grouped_by_customer] == 'true'
  end
end
