# frozen_string_literal: true

class OperationResultsRepository
  include Singleton

  def operation_results_for_company_month(company, month, year)
    OperationResult.where('company_id = :company_id AND EXTRACT(MONTH FROM result_date) = :month AND EXTRACT(YEAR FROM result_date) = :year', company_id: company.id, month: month, year: year)
  end
end
