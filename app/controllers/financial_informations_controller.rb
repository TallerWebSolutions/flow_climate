# frozen_string_literal: true

class FinancialInformationsController < AuthenticatedController
  before_action :user_gold_check

  before_action :assign_financial_information, only: %i[edit update destroy]

  def new
    @financial_information = FinancialInformation.new
  end

  def edit; end

  def create
    @financial_information = FinancialInformation.new(finances_params.merge(company: @company))
    return redirect_to company_path(@company) if @financial_information.save

    render :new
  end

  def update
    @financial_information.update(finances_params)
    return redirect_to company_path(@company) if @financial_information.save

    render :edit
  end

  def destroy
    @financial_information.destroy
    redirect_to company_path(@company)
  end

  private

  def finances_params
    params.require(:financial_information).permit(:finances_date, :income_total, :expenses_total)
  end

  def assign_financial_information
    @financial_information = FinancialInformation.find(params[:id])
  end
end
