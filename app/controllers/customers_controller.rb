# frozen_string_literal: true

class CustomersController < AuthenticatedController
  before_action :user_gold_check
  before_action :assign_company
  before_action :assign_customer, only: %i[edit update show destroy]

  def index
    @customers = @company.customers.sort_by(&:total_flow_pressure).reverse

    @start_date = @customers.map(&:projects).flatten.map(&:start_date).min
    @end_date = @customers.map(&:projects).flatten.map(&:end_date).max
  end

  def show
    @customer_dashboard_data = CustomerDashboardData.new(@customer)
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

  private

  def customer_projects
    @customer_projects ||= @customer.projects.order(end_date: :desc)
  end

  def assign_customer
    @customer = @company.customers.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(:name)
  end
end
