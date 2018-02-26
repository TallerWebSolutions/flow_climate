# frozen_string_literal: true

class DemandsRepository
  include Singleton

  def demands_for_company_and_week(company, required_date)
    Demand.joins(project_result: { project: :customer }).where('customers.company_id = :company_id AND EXTRACT(week FROM project_results.result_date) = :week AND EXTRACT(year FROM project_results.result_date) = :year', company_id: company.id, week: required_date.cweek, year: required_date.cwyear).order(:demand_id)
  end

  def create_or_update_demand(project, demand_id, demand_type, url)
    demand = Demand.where(project: project, demand_id: demand_id).first_or_initialize
    demand.update(demand_type: demand_type, url: url)
    demand
  end
end
