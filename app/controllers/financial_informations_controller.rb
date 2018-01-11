# frozen_string_literal: true

class FinancialInformationsController < AuthenticatedController
  before_action :assign_company

  def new
    @financial_information = FinancialInformation.new
  end

  def create
    @financial_information = FinancialInformation.new(finances_params.merge(company: @company))
    return redirect_to company_path(@company) if @financial_information.save
    render :new
  end

  private

  def finances_params
    params.require(:financial_information).permit(:finances_date, :income_total, :expenses_total)
  end
end
