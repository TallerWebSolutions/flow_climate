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

  def flow_pressure_in_week_for_projects(projects)
    build_hash_data_with_average(projects, :flow_pressure)
  end

  def hours_per_demand_in_time_for_projects(projects)
    hours_upstream_hash = build_hash_data_with_sum(projects, :qty_hours_upstream)
    hours_downstream_hash = build_hash_data_with_sum(projects, :qty_hours_downstream)
    throughput_hash = build_hash_data_with_sum(projects, :throughput)

    hours_per_demand_hash = {}
    throughput_hash.each do |key, value|
      hours_per_demand = (hours_upstream_hash[key] + hours_downstream_hash[key]).to_f / value.to_f
      hours_per_demand_hash[key] = hours_per_demand
    end

    hours_per_demand_hash
  end

  def throughput_for_projects_grouped_per_week(projects)
    build_hash_data_with_sum(projects, :throughput)
  end

  def delivered_until_week(projects, week, year)
    ProjectResult.until_week(week, year).where(project_id: projects.pluck(:id)).sum(:throughput)
  end

  def average_demand_cost_in_week_for_projects(projects)
    cost_in_month = build_hash_data_with_average(projects, :cost_in_month)
    throughput_hash = build_hash_data_with_sum(projects, :throughput)

    average_demand_cost_hash = {}
    throughput_hash.each do |key, value|
      average_cost = (cost_in_month[key] / 4).to_f / value.to_f
      average_demand_cost_hash[key] = average_cost
    end

    average_demand_cost_hash
  end

  def create_project_result(project, team, result_date)
    project_results = ProjectResult.where(result_date: result_date, project: project)
    return create_new_empty_project_result(result_date, project, team) if project_results.blank?
    project_results.first
  end

  def update_previous_and_current_demand_results(project, previous_result, current_result)
    [previous_result, current_result].each do |result|
      next if result.blank?
      update_result_for_date(project, result.result_date)
    end
  end

  def update_result_for_date(project, result_date)
    project_result = ProjectResult.where(result_date: result_date).last
    return if project_result.blank?

    results_without_transitions = previous_result_transitions(project)

    known_scope = project.demands.known_scope_to_date(result_date)
    known_scope += results_without_transitions.last.known_scope if results_without_transitions.present?

    compute_fields_and_update_result(known_scope, project, project_result, result_date)
    project_result
  end

  def update_results_greater_than(demands, min_date)
    demands.select(:project_id).group(:project_id).each do |project_id_hash|
      results_to_update = Project.find(project_id_hash.project_id).project_results.where('result_date >= :min_date', min_date: min_date)
      results_to_update.each { |result| update_result_for_date(result.project, result.result_date) }
    end
  end

  private

  def compute_fields_and_update_result(known_scope, project, project_result, result_date)
    finished_demands = project.demands.finished_until_date(result_date)
    created_in_date_demands = project.demands.created_until_date(result_date)
    demands_in_result = finished_demands + created_in_date_demands
    finished_bugs = project.demands.bug.finished_until_date(result_date)

    update_result(demands_in_result, finished_bugs, finished_demands, known_scope, project, project_result, result_date)
  end

  def previous_result_transitions(project)
    project.project_results.left_outer_joins(demands: :demand_transitions).where('demand_transitions.id IS NULL').order(:result_date)
  end

  def update_result(demands_in_result, finished_bugs, finished_demands, known_scope, project, project_result, result_date)
    project_result.update(demands: demands_in_result, known_scope: known_scope, throughput: finished_demands.count, qty_hours_upstream: 0, qty_hours_downstream: finished_demands.sum(:effort),
                          qty_hours_bug: finished_bugs.sum(:effort), qty_bugs_closed: finished_bugs.count, qty_bugs_opened: project.demands.bugs_opened_until_date_count(result_date),
                          remaining_days: project.remaining_days(result_date), flow_pressure: finished_demands.count.to_f / project.remaining_days(result_date),
                          average_demand_cost: average_demand_cost(finished_demands, project_result))
  end

  def build_hash_data_with_sum(projects, field)
    grouped_project_results(projects).sum(field)
  end

  def build_hash_data_with_average(projects, field)
    grouped_project_results(projects).average(field)
  end

  def grouped_project_results(projects)
    ProjectResult.select("date_trunc('week', result_date) AS week").where(project_id: projects.pluck(:id)).order("date_trunc('week', result_date)").group("date_trunc('week', result_date)")
  end

  def average_demand_cost(demands_for_date, project_result)
    return 0 if demands_for_date.blank?
    (project_result.cost_in_month / 30) / demands_for_date.count
  end

  def results_until_week(project, week, year)
    project.project_results.where('(EXTRACT(WEEK FROM result_date) <= :week AND EXTRACT(YEAR FROM result_date) <= :year) OR (EXTRACT(YEAR FROM result_date) < :year)', week: week, year: year).order(:result_date)
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
