# frozen_string_literal: true

class DemandsRepository
  include Singleton

  def known_scope_to_date(projects, analysed_date)
    Demand.story
          .where(project_id: projects.map(&:id))
          .where('created_date <= :analysed_date AND (discarded_at IS NULL OR discarded_at > :limit_date)', analysed_date: analysed_date.end_of_day, limit_date: analysed_date.beginning_of_day).uniq.count
  end

  def committed_demands_by_project_and_week(projects, week, year)
    Demand.kept.story.where(project_id: projects.map(&:id)).where('EXTRACT(WEEK FROM commitment_date) = :week AND EXTRACT(YEAR FROM commitment_date) = :year', week: week, year: year)
  end

  def throughput_to_projects_and_period(projects, start_period, end_period)
    Demand.kept.story.where(project_id: projects.map(&:id)).where('end_date BETWEEN :start_period AND :end_period', start_period: start_period, end_period: end_period)
  end

  def demands_delivered_grouped_by_projects_to_period(projects, start_period, end_period)
    throughput_to_projects_and_period(projects, start_period, end_period).group_by(&:project_full_name)
  end

  def effort_upstream_grouped_by_month(projects, limit_date)
    effort_upstream_hash = {}
    Demand.kept
          .story
          .select('EXTRACT(YEAR from end_date) AS year, EXTRACT(MONTH from end_date) AS month, SUM(effort_upstream) AS computed_sum_effort')
          .where(project_id: projects.map(&:id))
          .where('end_date >= :limit_date', limit_date: limit_date)
          .order('year, month')
          .group('year, month')
          .map { |group_sum| effort_upstream_hash[[group_sum.year, group_sum.month]] = group_sum.computed_sum_effort.to_f }
    effort_upstream_hash
  end

  def grouped_by_effort_downstream_per_month(projects, limit_date)
    effort_downstream_hash = {}
    Demand.kept
          .story
          .select('EXTRACT(YEAR from end_date) AS year, EXTRACT(MONTH from end_date) AS month, SUM(effort_downstream) AS computed_sum_effort')
          .where(project_id: projects.map(&:id))
          .where('end_date >= :limit_date', limit_date: limit_date)
          .order('year, month')
          .group('year, month')
          .map { |group_sum| effort_downstream_hash[[group_sum.year, group_sum.month]] = group_sum.computed_sum_effort.to_f }
    effort_downstream_hash
  end

  def demands_to_projects(array_of_projects)
    DemandsList.kept.story.where(project_id: array_of_projects.map(&:id))
  end

  def scope_in_week_for_projects(projects, week, year)
    total_scope = 0
    projects.each { |project| total_scope += project.backlog_for(Date.commercial(year, week, 1)) }
    total_scope
  end

  def bugs_opened_until_limit_date(projects, date = Time.zone.today)
    Demand.kept.story.where(project_id: projects).where('created_date < :limit_date', limit_date: date).bug.count
  end

  def bugs_closed_until_limit_date(projects, limit_date = Time.zone.today)
    demands_for_projects_and_finished_until_limit_date(projects, limit_date).bug.count
  end

  def delivered_until_date_to_projects_in_stream(projects, stream, limit_date = Time.zone.today)
    demands_for_projects_and_finished_until_limit_date(projects, limit_date).finished_in_stream(stream)
  end

  def delivered_hours_in_month_for_projects(projects, date = Time.zone.today)
    demands_for_projects_finished_in_period(projects, date.beginning_of_month, date.end_of_month).sum(:effort_downstream) + demands_for_projects_finished_in_period(projects, date.beginning_of_month, date.end_of_month).sum(:effort_upstream)
  end

  def upstream_throughput_in_month_for_projects(projects, date = Time.zone.today)
    demands_for_projects_finished_in_period(projects, date.beginning_of_month, date.end_of_month).finished_in_stream('upstream')
  end

  def downstream_throughput_in_month_for_projects(projects, date = Time.zone.today)
    demands_for_projects_finished_in_period(projects, date.beginning_of_month, date.end_of_month).finished_in_stream('downstream')
  end

  def operational_data_per_week_to_projects(projects_ids, downstream, date = Time.zone.today)
    operational_weekly_data = {}

    base_query_to_operational_data(date, downstream, projects_ids)
      .map do |operational_data_to_week|
      operational_weekly_data[Date.commercial(operational_data_to_week.year, operational_data_to_week.week, 1).end_of_week] = {
        total_effort_upstream: operational_data_to_week.total_effort_upstream.to_f,
        total_effort_downstream: operational_data_to_week.total_effort_downstream.to_f,
        throughput: operational_data_to_week.throughput,
        total_queue_time: operational_data_to_week.sum_total_queue_time.to_f,
        total_touch_time: operational_data_to_week.sum_total_queue_time.to_f
      }
    end

    operational_weekly_data
  end

  def count_grouped_per_period(demands, base_date_field, group_period = 'week')
    if group_period == 'day'
      build_count_grouped_per_period_query(demands, "DATE_TRUNC('day', #{base_date_field})::date", base_date_field).size
    elsif group_period == 'week'
      build_count_grouped_per_period_query(demands, "DATE_TRUNC('week', #{base_date_field})::date", base_date_field).size
    elsif group_period == 'year'
      build_count_grouped_per_period_query(demands, "DATE_TRUNC('year', #{base_date_field})::date", base_date_field).size
    else
      build_count_grouped_per_period_query(demands, "DATE_TRUNC('month', #{base_date_field})::date", base_date_field).size
    end
  end

  def demands_for_period(demands, start_period, end_period)
    Demand.kept
          .story
          .where(id: demands.map(&:id)).where('end_date >= :bottom_limit AND end_date <= :upper_limit', bottom_limit: start_period, upper_limit: end_period)
  end

  def demands_for_period_accumulated(demands, upper_date_limit)
    Demand.kept
          .story
          .where(id: demands.map(&:id)).where('end_date <= :upper_limit', upper_limit: upper_date_limit)
  end

  def cumulative_flow_for_week(demands_ids, date, stream)
    start_date = date.beginning_of_week
    end_date = date.end_of_week

    cumulative_hash = {}
    Demand.story
          .joins(demand_transitions: :stage).select('stages.name AS stage_name, count(1) as stage_th')
          .where(id: demands_ids)
          .where('demand_transitions.last_time_in < :end_date', end_date: end_date)
          .where('demands.discarded_at IS NULL OR demands.discarded_at > :start_date', start_date: start_date)
          .where('stages.stage_stream = :stream', stream: Stage.stage_streams[stream])
          .order('stages.order').group('stages.id, stages.order')
          .map { |result| cumulative_hash[result['stage_name']] = result['stage_th'] }

    cumulative_hash
  end

  def total_time_for(projects, sum_field)
    result_array = Demand.kept
                         .select('EXTRACT(WEEK FROM end_date) AS sum_week', 'EXTRACT(YEAR FROM end_date) AS sum_year', "SUM(#{sum_field}) AS total_time")
                         .where('end_date IS NOT NULL')
                         .where(project_id: projects.map(&:id))
                         .group('demands.end_date')
                         .map { |group_sum| [group_sum.sum_week.to_i, group_sum.sum_year.to_i, group_sum.total_time] }

    build_hash_to_total_duration_query_result(result_array)
  end

  private

  def build_count_grouped_per_period_query(demands, select_string, base_date_field)
    Demand.kept.story.select(select_string).where(id: demands.map(&:id)).where("#{base_date_field} IS NOT NULL").order(Arel.sql(select_string)).group(select_string)
  end

  def base_query_to_operational_data(date, downstream, projects_ids)
    Demand.kept.story.select('EXTRACT(YEAR from end_date) AS year, EXTRACT(WEEK from end_date) AS week, SUM(effort_downstream) AS total_effort_downstream, SUM(effort_upstream) AS total_effort_upstream, COUNT(1) AS throughput, SUM(total_queue_time) AS sum_total_queue_time, SUM(total_touch_time) AS sum_total_touch_time')
          .where(downstream: downstream, project_id: projects_ids)
          .where('end_date >= :limit_date', limit_date: date)
          .order('year, week').group('year, week')
  end

  def demands_for_projects_finished_in_period(projects, start_period, end_period)
    Demand.kept.story.where(project_id: projects).where('end_date BETWEEN :start_period AND :end_period', start_period: start_period, end_period: end_period)
  end

  def demands_for_projects_and_finished_until_limit_date(projects, limit_date)
    Demand.kept.story.where(project_id: projects).where('end_date <= :limit_date', limit_date: limit_date)
  end

  def build_hash_to_total_duration_query_result(query_result_array)
    query_result_hash = {}
    query_result_array.each { |single_result| query_result_hash[[single_result[0], single_result[1]]] = single_result[2].to_f }
    query_result_hash
  end
end
