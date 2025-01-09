# frozen_string_literal: true

class CompaniesController < ApplicationController
  before_action :user_gold_check
  skip_before_action :assign_company, only: %i[new create index]
  before_action :assign_stages_list, only: %i[show update_settings]

  def index
    @companies = Current.user.companies.order(:name)
  end

  def show
    @financial_informations = @company.financial_informations.select(:id, :finances_date, :income_total, :expenses_total)
    @finances_hash_with_computed_informations = Highchart::FinancesChartsAdapter.new(@financial_informations).finances_hash_with_computed_informations

    assign_company_children
    assign_company_settings
    assign_integration_accounts_list
    assign_projects

    build_query_dates

    Current.user.update(last_company_id: @company.id)
  end

  def new
    @company = Company.new
  end

  def edit
    assign_users_in_company
  end

  def create
    @company = Company.new(company_params)
    @company.add_user(Current.user)
    return redirect_to company_path(@company) if @company.save

    render :new
  end

  def update
    @company.update(company_params)
    return redirect_to company_path(@company) if @company.save

    assign_users_in_company
    render :edit
  end

  def add_user
    user = User.find_by(email: params[:user_email])
    return redirect_to(edit_company_path(@company), error: I18n.t('general.user_not_found')) if user.blank?

    @company.add_user(user)
    redirect_to edit_company_path(@company)
  end

  def send_company_bulletin
    mail_sent = UserNotifierMailer.company_weekly_bulletin(User.where(id: Current.user.id), @company)&.deliver
    if mail_sent.instance_of?(Mail::Message)
      flash[:notice] = I18n.t('companies.send_company_bulletin.sent')
    else
      flash[:error] = I18n.t('companies.send_company_bulletin.error')
    end
    redirect_to company_path(@company)
  end

  def update_settings
    @company_settings = @company.company_settings
    @company_settings = CompanySettings.new(company: @company) if @company_settings.blank?
    @company_settings.update(company_settings_params)
    assign_integration_accounts_list
    respond_to { |format| format.js { render 'companies/update_settings' } }
  end

  def projects_tab
    assign_projects
    @projects_summary = ProjectsSummaryData.new(@projects.except(:limit, :offset))
    build_query_dates

    respond_to { |format| format.js { render 'projects/projects_tab' } }
  end

  def strategic_chart_tab
    @projects = @company.projects.order(end_date: :desc)
    build_query_dates
    @strategic_chart_data = Highchart::StrategicChartsAdapter.new(@company, @company.teams, @projects, @company.demands.kept, @start_date, @end_date, @period)
    assign_company_children
    respond_to { |format| format.js { render 'charts/strategic_charts' } }
  end

  def risks_tab
    @projects = @company.projects.order(end_date: :desc)
    build_query_dates
    @strategic_chart_data = Highchart::StrategicChartsAdapter.new(@company, @company.teams, @projects, @company.demands.kept, @start_date, @end_date, @period)
    @projects_risk_chart_data = Highchart::ProjectRiskChartsAdapter.new(@projects)

    respond_to { |format| format.js { render 'companies/risks_tab' } }
  end

  private

  def assign_projects
    @projects = @company.projects.distinct
                        .includes(:team)
                        .includes(:customers_projects)
                        .includes(customers_projects: :customer)
                        .includes(:customers)
                        .includes(:products)
                        .includes(products_projects: :product)
                        .order(end_date: :desc)
                        .page(page_param)

    @unpaged_projects = @projects.except(:limit, :offset)
  end

  def assign_company_children
    @products_list = @company.products.includes(:team).includes(:customer).order(name: :asc)
    @customers_list = @company.customers.order(name: :asc)
  end

  def assign_company_settings
    @company_settings = @company.company_settings || CompanySettings.new(company: @company)
  end

  def assign_integration_accounts_list
    @jira_accounts_list = @company.jira_accounts.order(:created_at)
  end

  def assign_stages_list
    @stages_list = @company.stages.order('stages.integration_pipe_id, stages.order').includes(stages_teams: :team).includes(:teams)
  end

  def assign_users_in_company
    @users_in_company = @company.user_company_roles.joins(:user).order('users.first_name, users.last_name')
  end

  def assign_company
    @company = Company.friendly.find(params[:id])
    not_found unless Current.user.companies.include?(@company)
  end

  def company_params
    params.require(:company).permit(:name, :abbreviation)
  end

  def company_settings_params
    params.require(:company_settings).permit(:max_active_parallel_projects, :max_flow_pressure)
  end

  def build_query_dates
    @start_date = build_limit_date(@projects.map(&:start_date).min)
    @end_date = build_limit_date(@projects.map(&:end_date).max)
  end

  def build_limit_date(date)
    [date, 4.weeks.ago].compact.max.to_date
  end
end
