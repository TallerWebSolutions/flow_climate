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

  def create_or_update_demand(project, team, demand_id, demand_type, commitment_date, created_date, end_date, url)
    demand = Demand.where(demand_id: demand_id).first_or_initialize
    prior_result = demand.project_result
    result_date = end_date&.to_date || created_date.to_date
    project_result = ProjectResultsRepository.instance.create_project_result(project, team, result_date)
    hours_consumed = DemandService.instance.compute_effort_for_dates(commitment_date, end_date)
    demand.update(project_result: project_result, demand_type: demand_type, created_date: created_date, commitment_date: commitment_date, end_date: end_date, effort: hours_consumed, url: url)
    known_scope = ProjectsRepository.instance.known_scope(project, result_date)
    ProjectResultsRepository.instance.update_result_for_date(project, result_date, known_scope, 0)

    update_prior_result(project, prior_result) if prior_result.present?
  end

  private

  def update_prior_result(project, prior_result)
    known_scope = ProjectsRepository.instance.known_scope(project, prior_result.result_date)
    ProjectResultsRepository.instance.update_result_for_date(project, prior_result.result_date, known_scope, 0)
  end
end
