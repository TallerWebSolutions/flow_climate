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
end
