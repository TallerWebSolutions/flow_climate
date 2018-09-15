# frozen_string_literal: true

class CompaniesController < AuthenticatedController
  before_action :assign_company, except: %i[new create index]
  before_action :assign_stages_list, only: %i[show update_settings]

  def index
    @companies = current_user.companies.order(:name)
  end

  def show
    @financial_informations = @company.financial_informations.select(:id, :finances_date, :income_total, :expenses_total).for_year(Time.zone.today.year)
    @finances_hash_with_computed_informations = Highchart::FinancesChartsAdapter.new(@financial_informations).finances_hash_with_computed_informations
    @teams = @company.teams.order(:name)
    @company_projects = @company.projects.order(end_date: :desc)
    @projects_summary = ProjectsSummaryData.new(@company_projects)
    assign_company_settings
    build_charts_data
  end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)
    @company.add_user(current_user)
    return redirect_to company_path(@company) if @company.save

    render :new
  end

  def edit
    assign_users_in_company
  end

  def update
    @company.update(company_params)
    return redirect_to company_path(@company) if @company.save

    assign_users_in_company
    render :edit
  end

  def add_user
    user = User.find_by(email: params[:user_email])
    return redirect_to(edit_company_path(@company), error: t('general.user_not_found')) if user.blank?

    @company.add_user(user)
    redirect_to edit_company_path(@company)
  end

  def send_company_bulletin
    UserNotifierMailer.company_weekly_bulletin(User.where(id: current_user.id), @company).deliver
    flash[:notice] = t('companies.send_company_bulletin.queued')
    redirect_to company_path(@company)
  end

  def update_settings
    @company_settings = @company.company_settings
    @company_settings = CompanySettings.new(company: @company) if @company_settings.blank?
    @company_settings.update(company_settings_params)
    respond_to { |format| format.js { render file: 'companies/update_settings.js.erb' } }
  end

  private

  def assign_company_settings
    @company_settings = @company.company_settings || CompanySettings.new(company: @company)
  end

  def build_charts_data
    @projects_risk_chart_data = Highchart::ProjectRiskChartsAdapter.new(@company_projects)
    @strategic_chart_data = Highchart::StrategicChartsAdapter.new(@company, @company.projects, @company.total_available_hours)
  end

  def assign_stages_list
    @stages_list = @company.stages.order(:order, :name)
  end

  def assign_users_in_company
    @users_in_company = @company.users.order(:first_name, :last_name)
  end

  def assign_company
    @company = Company.find(params[:id])
    not_found unless current_user.companies.include?(@company)
  end

  def company_params
    params.require(:company).permit(:name, :abbreviation)
  end

  def company_settings_params
    params.require(:company_settings).permit(:max_active_parallel_projects, :max_flow_pressure)
  end
end
