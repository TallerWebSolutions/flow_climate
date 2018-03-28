# frozen_string_literal: true

class DemandsRepository
  include Singleton

  def demands_for_company_and_week(company, required_date)
    Demand.joins(project_result: { project: :customer }).where('customers.company_id = :company_id AND EXTRACT(week FROM project_results.result_date) = :week AND EXTRACT(year FROM project_results.result_date) = :year', company_id: company.id, week: required_date.cweek, year: required_date.cwyear).order(:demand_id)
  end

  def known_scope_to_date(project, date)
    Demand.where('project_id = :project_id AND created_date::timestamp::date <= :cut_date', project_id: project.id, cut_date: date).uniq.count
  end

  def full_demand_destroy!(demand)
    project_result = demand.project_result
    project_result.remove_demand!(demand) if project_result.present?
    demand.destroy
  end

  def selected_grouped_by_project_and_week(projects, week, year)
    Demand.where(project_id: projects.pluck(:id)).where('EXTRACT(WEEK FROM commitment_date) = :week AND EXTRACT(YEAR FROM commitment_date) = :year', week: week, year: year)
  end

  def throughput_grouped_by_project_and_week(projects, week, year)
    Demand.where(project_id: projects.pluck(:id)).where('EXTRACT(WEEK FROM end_date) = :week AND EXTRACT(YEAR FROM end_date) = :year', week: week, year: year)
  end
end
