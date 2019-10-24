# frozen_string_literal: true

class CustomersController < AuthenticatedController
  before_action :user_gold_check
  before_action :assign_company
  before_action :assign_customer, only: %i[edit update show destroy projects_tab]

  def index
    @customers = @company.customers.sort_by(&:total_flow_pressure).reverse

    @start_date = @customers.map(&:projects).flatten.map(&:start_date).min
    @end_date = @customers.map(&:projects).flatten.map(&:end_date).max
  end

  def show
    build_query_dates
    @projects_summary = ProjectsSummaryData.new(customer_projects.except(:limit, :offset))
  end

  def new
    @customer = Customer.new(company: @company)
  end

  def create
    @customer = Customer.new(customer_params.merge(company: @company))
    return redirect_to company_customers_path(@company) if @customer.save

    render :new
  end

  def edit; end

  def update
    @customer.update(customer_params.merge(company: @company))
    return redirect_to company_customers_path(@company) if @customer.save

    render :edit
  end

  def destroy
    return redirect_to company_customers_path(@company) if @customer.destroy

    redirect_to(company_customers_path(@company), flash: { error: @customer.errors.full_messages.join(',') })
  end

  def projects_tab
    @projects = @customer.projects.includes(:customers).includes(:products).includes(:team).order(end_date: :desc).page(page_param)

    @projects_summary = ProjectsSummaryData.new(@projects.except(:limit, :offset))
    @target_name = @customer.name

    respond_to { |format| format.js { render 'projects/projects_tab' } }
  end

  private

  def customer_projects
    @customer_projects ||= @customer.projects.order(end_date: :desc)
  end

  def assign_customer
    @customer = Customer.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(:name)
  end

  def build_query_dates
    @start_date = build_limit_date(customer_projects.map(&:start_date).min)
    @end_date = build_limit_date(customer_projects.map(&:end_date).max)
  end
end
