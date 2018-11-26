# frozen_string_literal: true

class ProjectsRepository
  include Singleton

  def active_projects_in_month(projects, required_date)
    where_by_start_end_dates(projects.joins(:customer).active, required_date)
  end

  def hours_consumed_per_month(projects, required_date)
    active_projects = active_projects_in_month(projects, required_date)
    total_consumed = 0
    active_projects.each { |project| total_consumed += project.demands.finished_in_month(required_date.to_date.month, required_date.to_date.year).sum(&:total_effort) }
    total_consumed
  end

  def hours_consumed_per_week(projects, required_date)
    active_projects = active_projects_in_month(projects, required_date)
    total_consumed = 0
    active_projects.each { |project| total_consumed += project.demands.finished_in_week(required_date.cweek, required_date.cwyear).sum(&:total_effort) }
    total_consumed
  end

  def flow_pressure_to_month(projects, required_date)
    active_projects = active_projects_in_month(projects, required_date)
    total_flow_pressure = 0
    active_projects.each { |project| total_flow_pressure += project.flow_pressure }
    total_flow_pressure
  end

  def money_to_month(projects, required_date)
    active_projects_in_month(projects, required_date).sum(&:money_per_month)
  end

  def all_projects_for_team(team)
    Project.where('team_id = :team_id', team_id: team.id).order(end_date: :desc)
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

  def total_queue_time_for(projects)
    build_hash_total_duration_to_time_and_type(projects, true)
  end

  def total_touch_time_for(projects)
    build_hash_total_duration_to_time_and_type(projects, false)
  end

  def hours_per_stage(projects, limit_date)
    DemandTransition.kept.joins(:demand).joins(:stage).select('stages.name, stages.order, SUM(EXTRACT(EPOCH FROM (last_time_out - last_time_in))) AS sum_duration').where(demands: { project_id: projects.map(&:id) }).where('stages.end_point = false AND last_time_in >= :limit_date AND last_time_out IS NOT NULL', limit_date: limit_date.beginning_of_day).group('stages.name, stages.order').order('stages.order, stages.name').map { |group_sum| [group_sum.name, group_sum.order, group_sum.sum_duration] }
  end

  def finish_project!(project)
    project.demands.not_finished.each { |demand| demand.update(end_date: Time.zone.now) }
    project.update(status: :finished)
  end

  private

  def build_hash_total_duration_to_time_and_type(projects, queue = true)
    query_result_array = DemandTransition.kept
                                         .select('EXTRACT(WEEK FROM last_time_out) AS sum_week', 'EXTRACT(YEAR FROM last_time_out) AS sum_year, SUM(EXTRACT(EPOCH FROM (last_time_out - last_time_in))) AS sum_duration')
                                         .joins(demand: :project)
                                         .joins(:stage)
                                         .where(demands: { project_id: projects.map(&:id) })
                                         .where('stages.queue = :queue AND stages.stage_stream = 1', queue: queue)
                                         .order(Arel.sql('EXTRACT(WEEK FROM last_time_out), EXTRACT(YEAR FROM last_time_out)'))
                                         .group('EXTRACT(WEEK FROM last_time_out)', 'EXTRACT(YEAR FROM last_time_out)')
                                         .map { |group_sum| [group_sum.sum_week.to_i, group_sum.sum_year.to_i, group_sum.sum_duration] }

    build_hash_to_total_duration_query_result(query_result_array)
  end

  def build_hash_to_total_duration_query_result(query_result_array)
    query_result_hash = {}
    query_result_array.each { |single_result| query_result_hash[[single_result[0], single_result[1]]] = single_result[2].to_f }
    query_result_hash
  end

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
