# frozen_string_literal: true

class PortfolioUnitsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_product
  before_action :assign_portfolio_unit, only: %i[show destroy edit update]

  def new
    @portfolio_unit = PortfolioUnit.new(product: @product)
    @portfolio_unit.build_jira_portfolio_unit_config

    assign_portfolio_units_list
    assign_parent_portfolio_units_list

    respond_to { |format| format.js { render 'portfolio_units/new' } }
  end

  def create
    @portfolio_unit = PortfolioUnit.new(portfolio_unit_params.merge(product: @product))

    if @portfolio_unit.save
      flash[:notice] = I18n.t('general.messages.saved')
    else
      flash[:error] = @portfolio_unit.errors.full_messages.join(', ')
    end
    assign_parent_portfolio_units_list
    assign_portfolio_units_list

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

  def edit
    assign_portfolio_units_list
    assign_parent_portfolio_units_list
  end

  def update
    @portfolio_unit.update(portfolio_unit_params)
    if @portfolio_unit.valid?
      assign_portfolio_units_list
    else
      flash[:error] = @portfolio_unit.errors.full_messages.join(', ')
      assign_parent_portfolio_units_list
    end

    respond_to { |format| format.js { render 'portfolio_units/update' } }
  end

  private

  def assign_portfolio_units_list
    @portfolio_units = @product.portfolio_units.order(:name, :parent_id)
  end

  def assign_parent_portfolio_units_list
    assign_portfolio_units_list

    @parent_portfolio_units = @portfolio_units - [@portfolio_unit]
  end

  def assign_portfolio_unit
    @portfolio_unit = @product.portfolio_units.find(params[:id])
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
