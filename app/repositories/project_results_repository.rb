# frozen_string_literal: true

class ProjectResultsRepository
  include Singleton

  def project_results_for_company_month(company, date = Time.zone.today)
    project_result_joins.where('customers.company_id = :company_id AND EXTRACT(MONTH FROM result_date) = :month AND EXTRACT(YEAR FROM result_date) = :year', company_id: company.id, month: date.month, year: date.year)
  end

  def consumed_hours_in_month(company, date = Time.zone.today)
    project_result_joins.where('customers.company_id = :company_id AND EXTRACT(MONTH FROM result_date) = :month AND EXTRACT(YEAR FROM result_date) = :year', company_id: company.id, month: date.month, year: date.year).sum(&:project_delivered_hours)
  end

  def consumed_hours_in_week(projects)
    ProjectResult
      .where(project_id: projects.map(&:id)).select('EXTRACT(ISOYEAR FROM result_date) AS year, EXTRACT(WEEK FROM result_date) AS week, SUM((qty_hours_upstream + qty_hours_downstream)) AS week_delivered_hours')
      .group('EXTRACT(ISOYEAR FROM result_date)', 'EXTRACT(WEEK FROM result_date)')
      .order(Arel.sql('EXTRACT(ISOYEAR FROM result_date)'), Arel.sql('EXTRACT(WEEK FROM result_date)')).map { |delivered_hours| [delivered_hours.year, delivered_hours.week, delivered_hours.week_delivered_hours] }
  end

  def upstream_throughput_in_month_for_company(company, date = Time.zone.today)
    project_result_joins.where('customers.company_id = :company_id AND EXTRACT(MONTH FROM result_date) = :month AND EXTRACT(YEAR FROM result_date) = :year', company_id: company.id, month: date.month, year: date.year).sum(&:throughput_upstream)
  end

  def downstream_throughput_in_month_for_company(company, date = Time.zone.today)
    project_result_joins.where('customers.company_id = :company_id AND EXTRACT(MONTH FROM result_date) = :month AND EXTRACT(YEAR FROM result_date) = :year', company_id: company.id, month: date.month, year: date.year).sum(&:throughput_downstream)
  end

  def bugs_opened_in_month(projects, date = Time.zone.today)
    ProjectResult.where(project_id: projects).where('EXTRACT(MONTH FROM result_date) = :month AND EXTRACT(YEAR FROM result_date) = :year', month: date.month, year: date.year).sum(&:qty_bugs_opened)
  end

  def bugs_closed_in_month(projects, date = Time.zone.today)
    ProjectResult.where(project_id: projects).where('EXTRACT(MONTH FROM result_date) = :month AND EXTRACT(YEAR FROM result_date) = :year', month: date.month, year: date.year).sum(&:qty_bugs_closed)
  end

  def bugs_opened_in_week(projects, date = Time.zone.today)
    ProjectResult.where(project_id: projects).where('EXTRACT(WEEK FROM result_date) = :week AND EXTRACT(YEAR FROM result_date) = :year', week: date.cweek, year: date.cwyear).sum(&:qty_bugs_opened)
  end

  def bugs_opened_until_week(projects, date = Time.zone.today)
    ProjectResult.where(project_id: projects).where('(EXTRACT(WEEK FROM result_date) <= :week AND EXTRACT(YEAR FROM result_date) <= :year) OR (EXTRACT(YEAR FROM result_date) < :year)', week: date.cweek, year: date.cwyear).sum(&:qty_bugs_opened)
  end

  def bugs_closed_in_week(projects, date = Time.zone.today)
    ProjectResult.where(project_id: projects).where('EXTRACT(WEEK FROM result_date) = :week AND EXTRACT(YEAR FROM result_date) = :year', week: date.cweek, year: date.cwyear).sum(&:qty_bugs_closed)
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
    return {} if projects.blank?
    hours_upstream_hash = build_hash_data_with_sum(projects, :qty_hours_upstream)
    hours_downstream_hash = build_hash_data_with_sum(projects, :qty_hours_downstream)
    upstream_throughput_hash = build_hash_data_with_sum(projects, :throughput_upstream)
    downstream_throughput_hash = build_hash_data_with_sum(projects, :throughput_downstream)

    throughput_hash = upstream_throughput_hash.merge(downstream_throughput_hash)

    hours_per_demand_hash = {}
    throughput_hash.each do |key, value|
      hours_per_demand = (hours_upstream_hash[key] + hours_downstream_hash[key]).to_f / value.to_f
      hours_per_demand_hash[key] = hours_per_demand
    end

    hours_per_demand_hash
  end

  def throughput_for_projects_grouped_per_week(projects, stage_stream)
    return build_hash_data_with_sum(projects, :throughput_upstream) if stage_stream == :upstream
    build_hash_data_with_sum(projects, :throughput_downstream)
  end

  def average_demand_cost_in_week_for_projects(projects)
    return {} if projects.blank?

    cost_in_month = build_hash_data_with_average(projects, :cost_in_month)
    upstream_throughput_hash = build_hash_data_with_sum(projects, :throughput_upstream)
    downstream_throughput_hash = build_hash_data_with_sum(projects, :throughput_downstream)

    throughput_hash = upstream_throughput_hash.merge(downstream_throughput_hash)

    average_demand_cost_hash = {}
    throughput_hash.each do |key, value|
      average_cost = (cost_in_month[key] / 4).to_f / value.to_f
      average_demand_cost_hash[key] = average_cost
    end

    average_demand_cost_hash
  end

  def sum_field_in_grouped_per_month_project_results(projects, field_to_sum)
    ProjectResult.where(project_id: projects.map(&:id)).group('EXTRACT(YEAR FROM result_date)', 'EXTRACT(MONTH FROM result_date)').order(Arel.sql('EXTRACT(YEAR FROM result_date)'), Arel.sql('EXTRACT(MONTH FROM result_date)')).sum(field_to_sum)
  end

  private

  def build_hash_data_with_sum(projects, field)
    grouped_per_week_project_results_to_projects(projects).sum(field)
  end

  def build_hash_data_with_average(projects, field)
    return 0 if projects.blank?
    grouped_per_week_project_results_to_projects(projects).average(field)
  end

  def grouped_per_week_project_results_to_projects(projects)
    return [] if projects.blank?
    ProjectResult.where(project_id: projects.map(&:id)).order(Arel.sql("DATE_TRUNC('WEEK', result_date)")).group("DATE_TRUNC('WEEK', result_date)")
  end

  def results_until_week(project, week, year)
    project.project_results.where('(EXTRACT(WEEK FROM result_date) <= :week AND EXTRACT(YEAR FROM result_date) <= :year) OR (EXTRACT(YEAR FROM result_date) < :year)', week: week, year: year).order(:result_date)
  end

  def project_result_joins
    ProjectResult.joins(project: [{ product: :customer }])
  end
end
