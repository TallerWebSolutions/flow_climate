# frozen_string_literal: true

class ProductsController < AuthenticatedController
  before_action :user_gold_check

  before_action :assign_company
  before_action :assign_product, only: %i[show edit update destroy]

  def index
    @products = @company.products.order(:name)
  end

  def show
    @product_projects = @product.projects.order(end_date: :desc)
    @portfolio_units = @product.portfolio_units.order(:name)
    @projects_summary = ProjectsSummaryData.new(@product.projects)
    @jira_product_configs = @product.jira_product_configs.order(:jira_product_key)
    render :show
  end

  def new
    @product = Product.new
    assign_customers
  end

  def edit
    assign_customers
  end

  def update
    customer = Customer.find_by(id: product_params[:customer_id])
    @product.update(product_params.merge(customer: customer))
    return redirect_to company_products_path(@company) if @product.save

    assign_customers
    render :edit
  end

  def create
    customer = Customer.find_by(id: product_params[:customer_id])
    @product = Product.new(product_params.merge(customer: customer))
    return redirect_to company_products_path(@company) if @product.save

    assign_customers
    render :new
  end

  def products_for_customer
    render_products_for_customer('products/products.js.erb', params[:customer_id])
  end

  def destroy
    @product.destroy
    redirect_to company_products_path(@company)
  end

  private

  def product_params
    params.require(:product).permit(:customer_id, :name)
  end

  def assign_product
    @product = Product.find(params[:id])
  end
end
