# frozen_string_literal: true

class ProjectResultsRepository
  include Singleton

  def project_results_for_company_month(company, month, year)
    project_result_joins.where('customers.company_id = :company_id AND EXTRACT(MONTH FROM result_date) = :month AND EXTRACT(YEAR FROM result_date) = :year', company_id: company.id, month: month, year: year)
  end

  def consumed_hours_in_week(company, week, year)
    project_result_joins.where('customers.company_id = :company_id AND EXTRACT(WEEK FROM result_date) = :week AND EXTRACT(YEAR FROM result_date) = :year', company_id: company.id, week: week, year: year).sum(&:project_delivered_hours)
  end

  def th_in_week_for_company(company, week, year)
    project_result_joins.where('customers.company_id = :company_id AND EXTRACT(WEEK FROM result_date) = :week AND EXTRACT(YEAR FROM result_date) = :year', company_id: company.id, week: week, year: year).sum(&:throughput)
  end

  def th_in_week_for_projects(projects, week, year)
    ProjectResult.where('project_id in (:project_ids) AND EXTRACT(WEEK FROM result_date) = :week AND EXTRACT(YEAR FROM result_date) = :year', project_ids: projects.pluck(:id), week: week, year: year).sum(:throughput)
  end

  def bugs_opened_in_week(company, week, year)
    project_result_joins.where('customers.company_id = :company_id AND EXTRACT(WEEK FROM result_date) = :week AND EXTRACT(YEAR FROM result_date) = :year', company_id: company.id, week: week, year: year).sum(&:qty_bugs_opened)
  end

  def bugs_closed_in_week(company, week, year)
    project_result_joins.where('customers.company_id = :company_id AND EXTRACT(WEEK FROM result_date) = :week AND EXTRACT(YEAR FROM result_date) = :year', company_id: company.id, week: week, year: year).sum(&:qty_bugs_closed)
  end

  def scope_in_week_for_projects(projects, week, year)
    total_scope = 0
    projects.each do |project|
      known_scope = results_until_week(project, week, year).last&.known_scope
      total_scope += known_scope || project.initial_scope
    end

    total_scope
  end

  def flow_pressure_in_week_for_projects(projects, week, year)
    total_flow_pressure = 0
    projects.each do |project|
      flow_pressure = results_until_week(project, week, year).last&.flow_pressure
      total_flow_pressure += flow_pressure.to_f || 0
    end

    total_flow_pressure
  end

  def hours_per_demand_in_time_for_projects(projects)
    hours_upstream_hash = build_hash_data(projects, :qty_hours_upstream)
    hours_downstream_hash = build_hash_data(projects, :qty_hours_downstream)
    hours_throughput_hash = build_hash_data(projects, :throughput)

    hours_per_demand_hash = {}
    hours_throughput_hash.each do |key, value|
      hours_per_demand = (hours_upstream_hash[key] + hours_downstream_hash[key]).to_f / value.to_f
      hours_per_demand_hash[key] = hours_per_demand
    end

    hours_per_demand_hash
  end

  def throughput_in_week_for_projects(projects)
    build_hash_data(projects, :throughput)
  end

  def average_demand_cost_in_week_for_projects(projects, week, year)
    results = results_for_week(week, year).where(project_id: projects.pluck(:id))

    avg_cost = results.average(:cost_in_month).to_f
    th_in_week = th_in_week_for_projects(projects, week, year)

    return 0 if avg_cost.blank? || th_in_week.blank?

    (avg_cost / 4) / th_in_week
  end

  def update_result_for_date(project, result_date, known_scope, qty_bugs_opened)
    project_result = ProjectResult.where(result_date: result_date).last
    return if project_result.blank?

    demands_for_date = Demand.where('DATE(end_date) = :end_date', end_date: result_date.to_date)
    bug_demands = demands_for_date.where(demand_type: :bug)

    project_result.update(known_scope: known_scope, throughput: demands_for_date.count, qty_hours_upstream: 0, qty_hours_downstream: demands_for_date.sum(:effort), qty_hours_bug: bug_demands.sum(:effort),
                          qty_bugs_closed: bug_demands.count, qty_bugs_opened: qty_bugs_opened, remaining_days: project.remaining_days(result_date),
                          flow_pressure: demands_for_date.count.to_f / project.remaining_days(result_date), average_demand_cost: average_demand_cost(demands_for_date, project_result))
    project_result
  end

  def create_project_result(project, team, result_date)
    project_results = ProjectResult.where(result_date: result_date, project: project)
    return create_new_empty_project_result(result_date, project, team) if project_results.blank?
    project_results.first
  end

  private

  def build_hash_data(projects, field)
    ProjectResult.select("date_trunc('week', result_date) AS week").where(project_id: projects.pluck(:id)).order("date_trunc('week', result_date)").group("date_trunc('week', result_date)").sum(field)
  end

  def average_demand_cost(demands_for_date, project_result)
    return 0 if demands_for_date.blank?
    (project_result.cost_in_month / 30) / demands_for_date.count
  end

  def results_until_week(project, week, year)
    project.project_results.where('(EXTRACT(WEEK FROM result_date) <= :week AND EXTRACT(YEAR FROM result_date) <= :year) OR (EXTRACT(YEAR FROM result_date) < :year)', week: week, year: year).order(:result_date)
  end

  def results_for_week(week, year)
    ProjectResult.where('EXTRACT(week FROM result_date) = :week AND EXTRACT(year FROM result_date) = :year', week: week, year: year)
  end

  def project_result_joins
    ProjectResult.joins(project: [{ product: :customer }])
  end

  def create_new_empty_project_result(result_date, project, team)
    ProjectResult.create(project: project, result_date: result_date, known_scope: 0, throughput: 0, qty_hours_upstream: 0,
                         qty_hours_downstream: 0, qty_hours_bug: 0, qty_bugs_closed: 0, qty_bugs_opened: 0,
                         team: team, flow_pressure: 0, remaining_days: project.remaining_days(result_date), cost_in_month: team.outsourcing_cost,
                         average_demand_cost: 0, available_hours: team.current_outsourcing_monthly_available_hours)
  end
end
