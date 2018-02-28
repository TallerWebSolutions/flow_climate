# frozen_string_literal: true

class DemandsRepository
  include Singleton

  def demands_for_company_and_week(company, required_date)
    Demand.joins(project_result: { project: :customer }).where('customers.company_id = :company_id AND EXTRACT(week FROM project_results.result_date) = :week AND EXTRACT(year FROM project_results.result_date) = :year', company_id: company.id, week: required_date.cweek, year: required_date.cwyear).order(:demand_id)
  end

  def create_or_update_demand(project, demand_id, demand_type, class_of_service, url)
    demand = Demand.where(project: project, demand_id: demand_id).first_or_initialize
    demand.update(demand_type: demand_type, class_of_service: class_of_service, url: url)
    demand
  end

  def known_scope_to_date(project, date)
    Demand.joins(:demand_transitions).where('project_id = :project_id AND (SELECT MIN(DATE(demand_transitions.last_time_in)) FROM demand_transitions WHERE demand_transitions.demand_id = demands.id) <= :cut_date', project_id: project.id, cut_date: date).uniq.count
  end
end
