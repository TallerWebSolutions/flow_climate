# frozen_string_literal: true

class ProductsController < AuthenticatedController
  before_action :user_gold_check

  before_action :assign_company
  before_action :assign_product, only: %i[show edit update destroy portfolio_units_tab projects_tab portfolio_charts_tab risk_reviews_tab service_delivery_reviews_tab]
  before_action :assign_demands, only: %i[portfolio_charts_tab]

  def index
    @products = @company.products.order(:name).includes(:customer).includes(:projects).includes(products_projects: :project)
    assign_filter_parameters_to_charts
  end

  def show
    @jira_product_configs = @product.jira_product_configs.order(:jira_product_key)
    assign_filter_parameters_to_charts
    assign_demands_ids

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
    if @product.destroy
      flash[:notice] = I18n.t('general.destroy.success')
    else
      flash[:error] = @product.errors.full_messages.join(' | ')
    end

    redirect_to company_products_path(@company)
  end

  def portfolio_units_tab
    @portfolio_units = @product.portfolio_units.includes(:parent).includes(:children).includes(:jira_portfolio_unit_config).order(:name)

    respond_to { |format| format.js { render 'portfolio_units/portfolio_units_tab' } }
  end

  def projects_tab
    @projects = @product.projects.includes(:customers).includes(:products).includes(:team).order(end_date: :desc).page(page_param)

    @projects_summary = ProjectsSummaryData.new(@projects.except(:limit, :offset))
    @target_name = @product.name
    assign_filter_parameters_to_charts

    respond_to { |format| format.js { render 'projects/projects_tab' } }
  end

  def portfolio_charts_tab
    assign_filter_parameters_to_charts

    @demands_chart_adapter = Highchart::DemandsChartsAdapter.new(@demands, @start_date, @end_date, @period) if @demands.present?

    respond_to { |format| format.js { render 'portfolio_units/portfolio_charts_tab' } }
  end

  def risk_reviews_tab
    @risk_reviews = @product.risk_reviews.order(meeting_date: :desc)
    respond_to { |format| format.js { render 'risk_reviews/risk_reviews_tab' } }
  end

  def service_delivery_reviews_tab
    @service_delivery_reviews = @product.service_delivery_reviews.order(meeting_date: :desc)
    respond_to { |format| format.js { render 'service_delivery_reviews/service_delivery_reviews_tab' } }
  end

  private

  def assign_demands
    @demands = @product.demands.kept.order(end_date: :desc)
  end

  def product_params
    params.require(:product).permit(:customer_id, :name)
  end

  def assign_product
    @product = Product.find(params[:id])
  end

  def assign_filter_parameters_to_charts
    @start_date = params[:start_date]&.to_date || [@demands&.map(&:created_date)&.min, 3.months.ago].compact.max.to_date
    @end_date = params[:end_date]&.to_date || Time.zone.today
    @period = params[:period] || 'month'
  end

  def assign_demands_ids
    @demands_ids = @product.demands.map(&:id)
  end
end
