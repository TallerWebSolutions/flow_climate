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

  def show; end

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
end
