# frozen_string_literal: true

require 'csv'

class PortfolioUnitsController < AuthenticatedController
  before_action :assign_product, except: :index
  before_action :assign_portfolio_unit, only: %i[show destroy edit update]

  def index
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end

  def show
    @demands = @portfolio_unit.total_portfolio_demands.kept.order(end_date: :desc)
    @portfolio_data = Highchart::PortfolioChartsAdapter.new(@projects, @start_date, @end_date, '') if @projects.present?
    assign_filter_parameters_to_charts
    @demands_chart_adapter = Highchart::DemandsChartsAdapter.new(@demands, @start_date, @end_date, @period) if @demands.present?
    @lead_time_breakdown = DemandService.instance.lead_time_breakdown(@demands.kept.finished_with_leadtime)
  end

  def new
    @portfolio_unit = PortfolioUnit.new(product: @product)
    @portfolio_unit.build_jira_portfolio_unit_config

    assign_portfolio_units_list
    assign_parent_portfolio_units_list

    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end

  def edit
    assign_portfolio_units_list
    assign_parent_portfolio_units_list
  end

  def create
    @portfolio_unit = PortfolioUnit.new(portfolio_unit_params.merge(product: @product))

    if @portfolio_unit.save
      flash[:notice] = I18n.t('portfolio_units.create.success')
    else
      flash[:error] = @portfolio_unit.errors.full_messages.join(', ')
      assign_portfolio_units_list
      assign_parent_portfolio_units_list
    end

    redirect_to company_product_portfolio_units_path(@company, @product)
  end

  def update
    @portfolio_unit.update(portfolio_unit_params)
    if @portfolio_unit.valid?
      flash[:notice] = I18n.t('portfolio_units.update.success')
      assign_portfolio_units_list
    else
      flash[:error] = @portfolio_unit.errors.full_messages.join(', ')
      assign_parent_portfolio_units_list
    end

    redirect_to company_product_portfolio_units_path(@company, @product)
  end

  def destroy
    @portfolio_unit.destroy
    flash[:notice] = I18n.t('portfolio_units.destroy.success')
    redirect_to company_product_portfolio_units_path(@company, @product)
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
    @product = @company.products.friendly.find(params[:product_id])
  end

  def portfolio_unit_params
    params.require(:portfolio_unit).permit(:parent_id, :portfolio_unit_type, :name, jira_portfolio_unit_config_attributes: [:jira_field_name])
  end

  def assign_filter_parameters_to_charts
    @start_date = params[:start_date]&.to_date || [@demands.map(&:created_date).min, 3.months.ago.to_date].compact.max
    @end_date = params[:end_date]&.to_date || Time.zone.today
    @period = params[:period] || 'month'
  end
end
