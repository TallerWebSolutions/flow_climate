# frozen_string_literal: true

class ProjectsController < AuthenticatedController
  before_action :user_gold_check

  before_action :assign_company
  before_action :assign_customer, only: %i[create update]
  before_action :assign_product, only: %i[create update]
  before_action :assign_project, only: %i[show edit update destroy synchronize_jira finish_project statistics copy_stages_from demands_blocks_tab demands_blocks_csv]

  def show
    @ordered_project_risk_alerts = @project.project_risk_alerts.order(created_at: :desc)
    @project_change_deadline_histories = @project.project_change_deadline_histories.includes(:user)
    @project_stages = @project.stages.order(:order, :name)
    @projects_to_copy_stages_from = (@company.projects.includes(:customer).includes(:product) - [@project]).sort_by(&:full_name)
    @demands_ids = DemandsRepository.instance.demands_created_before_date_to_projects([@project]).map(&:id)

    @start_date = @project.start_date
    @end_date = @project.end_date
  end

  def index
    @projects = add_status_filter(Project.joins(:customer).where('customers.company_id = ?', @company.id)).order(end_date: :desc)
    @projects_summary = ProjectsSummaryData.new(@projects)
  end

  def new
    assign_customers
    @project = Project.new
    @products = []
  end

  def create
    @project = Project.new(project_params.merge(customer: @customer, product: @product))
    return redirect_to company_projects_path(@company) if @project.save

    assign_products_list
    assign_customers
    render :new
  end

  def edit
    assign_customers
    assign_products_list
  end

  def update
    check_change_in_deadline!
    @project.update(project_params.merge(customer: @customer, product: @product))
    return redirect_to company_project_path(@company, @project) if @project.save

    assign_customers
    assign_products_list
    render :edit
  end

  def product_options_for_customer
    render_products_for_customer('projects/product_options.js.erb', params[:customer_id])
  end

  def search_for_projects
    assign_projects
    @projects_summary = ProjectsSummaryData.new(@projects)
    respond_to { |format| format.js { render 'projects/projects_search' } }
  end

  def destroy
    @project.destroy
    redirect_to company_projects_path(@company)
  end

  def synchronize_jira
    if @project.project_jira_config.blank?
      flash[:alert] = I18n.t('projects.sync.jira.no_config_error')
    else
      synchronize_project
    end

    redirect_to company_project_path(@company, @project)
  end

  def finish_project
    ProjectsRepository.instance.finish_project!(@project)
    flash[:notice] = t('projects.finish_project.success_message')
    redirect_to company_project_path(@company, @project)
  end

  def statistics
    respond_to { |format| format.js { render 'projects/project_statistics' } }
  end

  def copy_stages_from
    @project_to_copy_stages_from = Project.find(params[:project_to_copy_stages_from])
    @project.update(stages: @project_to_copy_stages_from.stages) if @project.stages.empty?
    @project_stages = @project.reload.stages.order(:order, :name)
    respond_to { |format| format.js { render 'projects/copy_stages_from' } }
  end

  def demands_blocks_tab
    @demands_blocks = DemandBlocksRepository.instance.active_blocks_to_projects_and_period([@project], start_date_to_query, end_date_to_query).order(block_time: :desc)

    respond_to { |format| format.js { render 'demand_blocks/demands_blocks_tab' } }
  end

  def demands_blocks_csv
    @demands_blocks = DemandBlocksRepository.instance.active_blocks_to_projects_and_period([@project], start_date_to_query, end_date_to_query).order(block_time: :desc)

    attributes = %w[id block_time unblock_time block_duration demand_id]
    blocks_csv = CSV.generate(headers: true) do |csv|
      csv << attributes
      @demands_blocks.each { |block| csv << block.csv_array }
    end
    respond_to { |format| format.csv { send_data blocks_csv, filename: "demands-blocks-#{Time.zone.now}.csv" } }
  end

  private

  def synchronize_project
    jira_account = Jira::JiraAccount.find_by(customer_domain: @project.project_jira_config.jira_account_domain)
    project_url = company_project_url(@company, @project)
    Jira::ProcessJiraProjectJob.perform_later(jira_account, @project.project_jira_config, current_user.email, current_user.full_name, project_url)
    flash[:notice] = t('general.enqueued')
  end

  def start_date_to_query
    (params['start_date'] || @project.start_date).to_date
  end

  def end_date_to_query
    (params['end_date'] || @project.end_date).to_date
  end

  def assign_projects
    projects_parent = customer || product || team || @company

    @projects = ProjectsRepository.instance.add_query_to_projects_in_status(projects_parent.projects.joins(:customer), params[:status_filter])
  end

  def customer
    @customer ||= Customer.find(params[:customer_id]) if params[:customer_id].present?
  end

  def product
    @product ||= Product.find(params[:product_id]) if params[:product_id].present?
  end

  def team
    @team ||= Team.find(params[:team_id]) if params[:team_id].present?
  end

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
    params.require(:project).permit(:customer_id, :product_id, :name, :nickname, :status, :project_type, :start_date, :end_date, :value, :qty_hours, :hour_value, :initial_scope, :percentage_effort_to_bugs, :team_id, :max_work_in_progress)
  end

  def assign_project
    @project = Project.includes(:team).includes(:product).includes(:customer).find(params[:id])
  end

  def add_status_filter(projects)
    return projects if params[:status_filter].blank? || projects.blank?

    projects.where(status: params[:status_filter])
  end

  def check_change_in_deadline!
    return if project_params[:end_date].blank? || @project.end_date == Date.parse(project_params[:end_date])

    ProjectChangeDeadlineHistory.create!(user: current_user, project: @project, previous_date: @project.end_date, new_date: project_params[:end_date])
  end
end
