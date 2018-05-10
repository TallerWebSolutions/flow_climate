# frozen_string_literal: true

class DemandsRepository
  include Singleton

  def demands_for_company_and_week(company, required_date)
    Demand.joins(project_result: { project: :customer }).where('customers.company_id = :company_id AND EXTRACT(week FROM project_results.result_date) = :week AND EXTRACT(year FROM project_results.result_date) = :year', company_id: company.id, week: required_date.cweek, year: required_date.cwyear).order(:demand_id)
  end

  def known_scope_to_date(project, analysed_date)
    Demand.where('project_id = :project_id AND DATE(created_date::TIMESTAMPTZ AT TIME ZONE INTERVAL :interval_value::INTERVAL) <= :analysed_date', project_id: project.id, interval_value: Time.zone.now.formatted_offset, analysed_date: analysed_date).uniq.count
  end

  def full_demand_destroy!(demand)
    project_result = demand.project_result
    project_result.remove_demand!(demand) if project_result.present?
    demand.destroy
  end

  def selected_grouped_by_project_and_week(projects, week, year)
    Demand.where(project_id: projects.map(&:id)).where('EXTRACT(WEEK FROM commitment_date) = :week AND EXTRACT(YEAR FROM commitment_date) = :year', week: week, year: year)
  end

  def throughput_by_project_and_week(projects, week, year)
    Demand.where(project_id: projects.map(&:id)).where('EXTRACT(WEEK FROM end_date) = :week AND EXTRACT(YEAR FROM end_date) = :year', week: week, year: year)
  end

  def work_in_progress_for(projects, analysed_date)
    demands = Demand.joins(:project).where(project_id: projects.map(&:id))
    demands_touched_in_day(demands, analysed_date).order(:commitment_date)
  end

  def grouped_by_effort_upstream_per_month(array_of_projects)
    Demand.finished.where(project_id: array_of_projects.map(&:id)).order(Arel.sql('EXTRACT(YEAR from end_date), EXTRACT(MONTH from end_date)')).group('EXTRACT(YEAR from end_date)', 'EXTRACT(MONTH from end_date)').sum(:effort_upstream)
  end

  def grouped_by_effort_downstream_per_month(array_of_projects)
    Demand.finished.where(project_id: array_of_projects.map(&:id)).order(Arel.sql('EXTRACT(YEAR from end_date), EXTRACT(MONTH from end_date)')).group('EXTRACT(YEAR from end_date)', 'EXTRACT(MONTH from end_date)').sum(:effort_downstream)
  end

  private

  def demands_touched_in_day(demands, analysed_date)
    demands.where('(demands.commitment_date <= :end_of_day AND demands.end_date IS NULL) OR (demands.commitment_date <= :end_of_day AND demands.end_date > :beginning_of_day)', beginning_of_day: analysed_date.beginning_of_day, end_of_day: analysed_date.end_of_day)
  end
end
