# frozen_string_literal: true

class ProjectsRepository
  include Singleton

  def active_projects_in_month(projects, required_date)
    where_by_start_end_dates(projects.joins(:customer).active, required_date)
  end

  def hours_consumed_per_month(projects, required_date)
    active_projects = active_projects_in_month(projects, required_date)
    total_consumed = 0
    active_projects.each { |project| total_consumed += project.project_results.in_month(required_date).sum(&:total_hours) }
    total_consumed
  end

  def hours_consumed_per_week(projects, required_date)
    active_projects = active_projects_in_month(projects, required_date)
    total_consumed = 0
    active_projects.each { |project| total_consumed += project.project_results.for_week(required_date.cweek, required_date.cwyear).sum(&:total_hours) }
    total_consumed
  end

  def flow_pressure_to_month(projects, required_date)
    active_projects = active_projects_in_month(projects, required_date)
    total_flow_pressure = 0
    active_projects.each do |project|
      results = project.project_results.in_month(required_date)
      total_flow_pressure += if results.present?
                               results.average(:flow_pressure).to_f
                             elsif required_date >= Time.zone.today.beginning_of_month
                               project.flow_pressure.to_f
                             else
                               0.0
                             end
    end
    total_flow_pressure
  end

  def money_to_month(projects, required_date)
    active_projects_in_month(projects, required_date).sum(&:money_per_month)
  end

  def search_project_by_full_name(full_name)
    Project.all.select { |p| p.full_name.casecmp(full_name.downcase).zero? }.first
  end

  def all_projects_for_team(team)
    Project.left_outer_joins(:project_results).left_outer_joins(:product).where('project_results.team_id = :team_id OR products.team_id = :team_id', team_id: team.id).order(end_date: :desc).distinct
  end

  def add_query_to_projects_in_status(projects, status_param)
    projects_with_query_and_order = projects
    projects_with_query_and_order = projects.where(status: status_param) if status_param != 'all'
    projects_with_query_and_order.order(end_date: :desc)
  end

  def throughput_per_week(projects, limit_date)
    throughput_per_week_grouped = Demand.where(project_id: projects.pluck(:id)).finished.where('end_date >= :limit_date', limit_date: limit_date.beginning_of_day).group('EXTRACT(WEEK FROM end_date)', 'EXTRACT(YEAR FROM end_date)').count
    extract_data_for_week(projects, throughput_per_week_grouped)
  end

  def leadtime_per_week(projects, limit_date)
    leadtime_per_week_grouped = Demand.where(project_id: projects.pluck(:id)).finished.where('end_date >= :limit_date', limit_date: limit_date.beginning_of_day).group('EXTRACT(WEEK FROM end_date)', 'EXTRACT(YEAR FROM end_date)').average(:leadtime)
    extract_data_for_week(projects, leadtime_per_week_grouped)
  end

  def total_queue_time_for(projects, date = Time.zone.today)
    DemandTransition.joins(demand: :project).joins(:stage).where(demands: { project_id: projects.map(&:id) }).where('stages.queue = true AND stages.stage_stream = 1 AND ((EXTRACT(WEEK FROM demand_transitions.last_time_out) <= :week AND EXTRACT(YEAR FROM demand_transitions.last_time_out) <= :year) OR (EXTRACT(YEAR FROM demand_transitions.last_time_out) < :year))', week: date.cweek, year: date.cwyear).uniq.sum(&:total_hours_in_transition)
  end

  def total_touch_time_for(projects, date = Time.zone.today)
    DemandTransition.joins(demand: :project).joins(:stage).where(demands: { project_id: projects.map(&:id) }).where('stages.queue = false AND stages.stage_stream = 1 AND ((EXTRACT(WEEK FROM demand_transitions.last_time_out) <= :week AND EXTRACT(YEAR FROM demand_transitions.last_time_out) <= :year) OR (EXTRACT(YEAR FROM demand_transitions.last_time_out) < :year))', week: date.cweek, year: date.cwyear).uniq.sum(&:total_hours_in_transition)
  end

  def hours_per_stage(projects, limit_date)
    DemandTransition.joins(:demand).joins(:stage).select('stages.name, stages.order, SUM(EXTRACT(EPOCH FROM (last_time_out - last_time_in))) AS sum_duration').where(demands: { project_id: projects.map(&:id) }).where('stages.end_point = false AND last_time_in >= :limit_date AND last_time_out IS NOT NULL', limit_date: limit_date.beginning_of_day).group('stages.name, stages.order').order('stages.order, stages.name').map { |group_sum| [group_sum.name, group_sum.order, group_sum.sum_duration] }
  end

  def finish_project!(project)
    project.demands.not_finished.each { |demand| demand.update(end_date: Time.zone.now) }
    project.update(status: :finished)
  end

  private

  def extract_data_for_week(projects, leadtime_per_week_grouped)
    return {} if projects.blank?
    start_date = projects.map(&:start_date).min
    end_date = [projects.map(&:end_date).max, Time.zone.today].min

    data_grouped_hash = {}
    (start_date..end_date).each do |date|
      data_grouped_hash[date.beginning_of_week] = leadtime_per_week_grouped[[date.to_date.cweek.to_f, date.to_date.cwyear.to_f]] || 0
    end
    data_grouped_hash
  end

  def where_by_start_end_dates(projects, required_date)
    projects.where('(start_date <= :end_date AND end_date >= :start_date) OR (start_date >= :start_date AND end_date <= :end_date) OR (start_date <= :end_date AND start_date >= :start_date)', start_date: required_date.beginning_of_month, end_date: required_date.end_of_month)
  end
end
