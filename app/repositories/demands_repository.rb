# frozen_string_literal: true

class DemandsRepository
  include Singleton

  def demands_for_company_and_week(company, required_date)
    Demand.joins(project_result: { project: :customer }).where('customers.company_id = :company_id AND EXTRACT(week FROM project_results.result_date) = :week AND EXTRACT(year FROM project_results.result_date) = :year', company_id: company.id, week: required_date.cweek, year: required_date.cwyear).order(:demand_id)
  end

  def update_demand_and_project_result(demand, hours_consumed, demand_type, created_date, commitment_date, end_date, known_scope, project, project_result)
    demand.update(project_result: project_result, demand_type: demand_type, created_date: created_date, end_date: end_date, commitment_date: commitment_date, effort: hours_consumed)
    ProjectResultsRepository.instance.update_result_for_date(project, demand.end_date, known_scope, 0)
  end
end
