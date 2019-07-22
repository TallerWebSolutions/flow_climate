# frozen_string_literal: true

class PortfolioUnitsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_product
  before_action :assign_portfolio_unit, only: %i[show destroy]

  def new
    @portfolio_unit = PortfolioUnit.new(product: @product)
    @portfolio_unit.build_jira_portfolio_unit_config
    @portfolio_units = @product.portfolio_units.order(:name)

    respond_to { |format| format.js { render 'portfolio_units/new' } }
  end

  def create
    @portfolio_unit = PortfolioUnit.new(portfolio_unit_params.merge(product: @product))

    flash[:error] = @portfolio_unit.errors.full_messages.join(', ') unless @portfolio_unit.save

    @portfolio_units = @product.portfolio_units.order(:name)
    respond_to { |format| format.js { render 'portfolio_units/create' } }
  end

  def destroy
    @portfolio_unit.destroy
    @portfolio_units = @product.portfolio_units.order(:name)
    render 'portfolio_units/destroy'
  end

  def show
    @demands = @portfolio_unit.total_portfolio_demands.kept.order(end_date: :desc)
    @portfolio_data = Highchart::PortfolioChartsAdapter.new(@projects, @start_date, @end_date, '') if @projects.present?
    assign_filter_parameters_to_charts
    @demands_chart_adapter = Highchart::DemandsChartsAdapter.new(@demands, @start_date, @end_date, @period) if @demands.present?
  end

  private

  def assign_portfolio_unit
    @portfolio_unit = PortfolioUnit.find(params[:id])
  end

  def assign_product
    @product = @company.products.find(params[:product_id])
  end

  def portfolio_unit_params
    params.require(:portfolio_unit).permit(:parent_id, :portfolio_unit_type, :name, jira_portfolio_unit_config_attributes: [:jira_field_name])
  end

  def assign_filter_parameters_to_charts
    @start_date = params[:start_date]&.to_date || [@demands.map(&:created_date).min, 3.months.ago.to_date].compact.max
    @end_date = params[:end_date]&.to_date || Time.zone.today
    @period = params[:period] || 'week'
  end
end
