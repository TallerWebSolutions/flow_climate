# frozen_string_literal: true

class ProjectsController < AuthenticatedController
  before_action :user_gold_check

  before_action :assign_company
  before_action :assign_product, only: %i[create update]
  before_action :assign_project, only: %i[show edit update destroy synchronize_jira finish_project statistics copy_stages_from]

  def show
    assign_project_stages

    @ordered_project_risk_alerts = @project.project_risk_alerts.order(created_at: :desc)
    @project_change_deadline_histories = @project.project_change_deadline_histories.includes(:user)
    @projects_to_copy_stages_from = (@company.projects.includes(:product) - [@project]).sort_by(&:name)
    @demands_ids = DemandsRepository.instance.demands_created_before_date_to_projects([@project]).map(&:id)

    @start_date = @project.start_date
    @end_date = @project.end_date
  end

  def index
    @projects = add_status_filter(Project.where('company_id = ?', @company.id)).order(end_date: :desc)
    @projects_summary = ProjectsSummaryData.new(@projects)
  end

  def new
    assign_customers
    @project = Project.new
    @products = []
  end

  def create
    @project = Project.new(project_params.merge(company: @company, product: @product))
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
    @project.update(project_params.merge(product: @product))

    return redirect_to company_project_path(@company, @project) if @project.save

    assign_customers
    assign_products_list
    render :edit
  end

  def product_options_for_customer
    render_products_for_customer('projects/product_options.js.erb', params[:customer_id])
  end

  def search_for_projects
    assign_parent
    @projects = @parent.projects.order(end_date: :desc)
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
    @project.update(stages: (@project.stages + @project_to_copy_stages_from.stages) - (@project.stages & @project_to_copy_stages_from.stages))
    assign_project_stages

    respond_to { |format| format.js { render 'stages/update_stages_table' } }
  end

  private

  def assign_project_stages
    @stages_list = @project.reload.stages.order(:order, :name)
  end

  def synchronize_project
    jira_account = @company.jira_accounts.first

    project_url = company_project_url(@company, @project)
    Jira::ProcessJiraProjectJob.perform_later(jira_account, @project.project_jira_config, current_user.email, current_user.full_name, project_url)
    flash[:notice] = t('general.enqueued')
  end

  def assign_parent
    @parent = if team?
                Team.find(params[:parent_id])
              elsif customer?
                Customer.find(params[:parent_id])
              elsif product?
                Product.find(params[:parent_id])
              else
                Company.find(params[:parent_id])
              end

    @parent_type = params[:parent_type]
  end

  def product?
    params[:parent_type] == 'product'
  end

  def customer?
    params[:parent_type] == 'customer'
  end

  def team?
    params[:parent_type] == 'team'
  end

  def assign_products_list
    @products = @company.products.order(:name) || []
  end

  def assign_product
    @product = Product.find_by(id: project_params[:product_id])
  end

  def project_params
    params.require(:project).permit(:product_id, :name, :nickname, :status, :project_type, :start_date, :end_date, :value, :qty_hours, :hour_value, :initial_scope, :percentage_effort_to_bugs, :team_id, :max_work_in_progress)
  end

  def assign_project
    @project = Project.includes(:team).includes(:product).find(params[:id])
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
