# frozen_string_literal: true

class OperationResultsController < AuthenticatedController
  before_action :assign_company

  def index
    @operation_results = @company.operation_results.order(result_date: :desc)
  end
end
