# frozen_string_literal: true

class ProjectResultsRepository
  include Singleton

  def project_results_for_company_month(company, month, year)
    project_result_joins.where('customers.company_id = :company_id AND EXTRACT(MONTH FROM result_date) = :month AND EXTRACT(YEAR FROM result_date) = :year', company_id: company.id, month: month, year: year)
  end

  def consumed_hours_in_week(company, week, year)
    project_result_joins.where('customers.company_id = :company_id AND EXTRACT(WEEK FROM result_date) = :week AND EXTRACT(YEAR FROM result_date) = :year', company_id: company.id, week: week, year: year).sum(&:project_delivered_hours)
  end

  def th_in_week(company, week, year)
    project_result_joins.where('customers.company_id = :company_id AND EXTRACT(WEEK FROM result_date) = :week AND EXTRACT(YEAR FROM result_date) = :year', company_id: company.id, week: week, year: year).sum(&:throughput)
  end

  def bugs_opened_in_week(company, week, year)
    project_result_joins.where('customers.company_id = :company_id AND EXTRACT(WEEK FROM result_date) = :week AND EXTRACT(YEAR FROM result_date) = :year', company_id: company.id, week: week, year: year).sum(&:qty_bugs_opened)
  end

  def bugs_closed_in_week(company, week, year)
    project_result_joins.where('customers.company_id = :company_id AND EXTRACT(WEEK FROM result_date) = :week AND EXTRACT(YEAR FROM result_date) = :year', company_id: company.id, week: week, year: year).sum(&:qty_bugs_closed)
  end

  private

  def project_result_joins
    ProjectResult.joins(project: [{ product: :customer }])
  end
end
