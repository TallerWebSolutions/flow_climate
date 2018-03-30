# frozen_string_literal: true

class CustomersController < AuthenticatedController
  before_action :assign_company
  before_action :assign_customer, only: %i[edit update show destroy search_for_projects]

  def index
    @customers = @company.customers.sort_by(&:total_flow_pressure).reverse
  end

  def show
    @customer_projects = @customer.projects.order(end_date: :desc)
    @projects_summary = ProjectsSummaryObject.new(@customer.projects)
    @report_data = ReportData.new(@customer_projects)
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

  def search_for_projects
    @projects = ProjectsRepository.instance.add_query_to_projects_in_status(@customer.projects, params[:status_filter])
    @projects_summary = ProjectsSummaryObject.new(@projects)
    respond_to { |format| format.js { render file: 'projects/projects_search.js.erb' } }
  end

  private

  def assign_customer
    @customer = Customer.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(:name)
  end
end
