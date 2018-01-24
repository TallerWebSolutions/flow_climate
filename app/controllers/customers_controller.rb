# frozen_string_literal: true

class CustomersController < AuthenticatedController
  before_action :assign_company
  before_action :assign_customer, only: %i[edit update]

  def index
    @customers = @company.customers.order(:name)
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

  private

  def assign_customer
    @customer = Customer.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(:name)
  end
end
