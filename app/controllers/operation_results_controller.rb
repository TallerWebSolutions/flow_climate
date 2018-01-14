# frozen_string_literal: true

class OperationResultsController < AuthenticatedController
  before_action :assign_company

  def index
    @operation_results = @company.operation_results.order(result_date: :desc)
  end

  def destroy
    @operation_result = OperationResult.find(params[:id])
    @operation_result.destroy
    redirect_to company_operation_results_path(@company)
  end

  def new
    @operation_result = OperationResult.new(company: @company)
  end

  def create
    @operation_result = OperationResult.new(operation_result_params.merge(company: @company))
    return redirect_to company_operation_results_path(@company) if @operation_result.save
    render :new
  end

  private

  def operation_result_params
    params.require(:operation_result).permit(:result_date, :people_billable_count, :operation_week_value, :available_hours, :delivered_hours, :total_th, :total_opened_bugs, :total_accumulated_closed_bugs)
  end
end
