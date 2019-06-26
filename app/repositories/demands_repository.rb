# frozen_string_literal: true

class DemandsRepository
  include Singleton

  def known_scope_to_date(projects, analysed_date)
    demands_created_before_date_to_projects(projects, analysed_date).count + projects.sum(&:initial_scope)
  end

  def remaining_backlog_to_date(projects, analysed_date)
    demands_created_before_date_to_projects(projects, analysed_date).where('(end_date IS NULL OR end_date > :analysed_date) AND (commitment_date IS NULL OR commitment_date > :analysed_date)', analysed_date: analysed_date).count + projects.sum(&:initial_scope)
  end

  def committed_demands_by_project_and_week(projects, week, year)
    demands_stories_to_projects(projects).where('EXTRACT(WEEK FROM commitment_date) = :week AND EXTRACT(YEAR FROM commitment_date) = :year', week: week, year: year)
  end

  def demands_delivered_grouped_by_projects_to_period(projects, start_period, end_period)
    throughput_to_projects_and_period(projects, start_period, end_period).group_by(&:project_name)
  end

  def throughput_to_projects_and_period(projects, start_period, end_period)
    demands_stories_to_projects(projects).where('end_date BETWEEN :start_period AND :end_period', start_period: start_period, end_period: end_period)
  end

  def created_to_projects_and_period(projects, start_period, end_period)
    demands_stories_to_projects(projects).where('created_date BETWEEN :start_period AND :end_period', start_period: start_period, end_period: end_period)
  end

  def effort_upstream_grouped_by_month(projects, start_date, end_date)
    effort_upstream_hash = {}
    Demand.kept
          .story
          .select('EXTRACT(YEAR from end_date) AS year, EXTRACT(MONTH from end_date) AS month, SUM(effort_upstream) AS computed_sum_effort')
          .where(project_id: projects.map(&:id))
          .where('end_date BETWEEN :start_date AND :end_date', start_date: start_date, end_date: end_date)
          .order('year, month')
          .group('year, month')
          .map { |group_sum| effort_upstream_hash[[group_sum.year, group_sum.month]] = group_sum.computed_sum_effort.to_f }
    effort_upstream_hash
  end

  def grouped_by_effort_downstream_per_month(projects, start_date, end_date)
    effort_downstream_hash = {}
    Demand.kept
          .story
          .select('EXTRACT(YEAR from end_date) AS year, EXTRACT(MONTH from end_date) AS month, SUM(effort_downstream) AS computed_sum_effort')
          .where(project_id: projects.map(&:id))
          .where('end_date BETWEEN :start_date AND :end_date', start_date: start_date, end_date: end_date)
          .order('year, month')
          .group('year, month')
          .map { |group_sum| effort_downstream_hash[[group_sum.year, group_sum.month]] = group_sum.computed_sum_effort.to_f }
    effort_downstream_hash
  end

  def demands_created_before_date_to_projects(projects, analysed_date = Time.zone.now)
    demands_list_to_projects(projects).where('demands_lists.created_date <= :analysed_date AND (demands_lists.discarded_at IS NULL OR demands_lists.discarded_at > :limit_date)', analysed_date: analysed_date, limit_date: analysed_date)
  end

  def bugs_opened_until_limit_date(projects, date = Time.zone.today)
    Demand.kept.story.where(project_id: projects).where('created_date < :limit_date', limit_date: date).bug.count
  end

  def bugs_closed_until_limit_date(projects, limit_date = Time.zone.today)
    demands_for_projects_and_finished_until_limit_date(projects, limit_date).bug.count
  end

  def delivered_until_date_to_projects_in_stream(projects, stream, limit_date = Time.zone.today)
    return demands_for_projects_and_finished_until_limit_date(projects, limit_date.end_of_day).finished_in_downstream if stream == 'downstream'

    demands_for_projects_and_finished_until_limit_date(projects, limit_date.end_of_day).finished_in_upstream
  end

  def delivered_hours_in_month_for_projects(projects, date = Time.zone.today)
    demands_for_projects_finished_in_period(projects, date.beginning_of_month, date.end_of_month).sum(:effort_downstream) + demands_for_projects_finished_in_period(projects, date.beginning_of_month, date.end_of_month).sum(:effort_upstream)
  end

  def upstream_throughput_in_month_for_projects(projects, date = Time.zone.today)
    demands_for_projects_finished_in_period(projects, date.beginning_of_month, date.end_of_month).finished_in_upstream
  end

  def downstream_throughput_in_month_for_projects(projects, date = Time.zone.today)
    demands_for_projects_finished_in_period(projects, date.beginning_of_month, date.end_of_month).finished_in_downstream
  end

  def demands_delivered_for_period(demands, start_period, end_period)
    Demand.kept
          .story
          .where(id: demands.map(&:id)).where('demands.end_date >= :bottom_limit AND demands.end_date <= :upper_limit', bottom_limit: start_period, upper_limit: end_period)
  end

  def demands_delivered_for_period_accumulated(demands, upper_date_limit)
    Demand.kept
          .story
          .where(id: demands.map(&:id)).where('demands.end_date <= :upper_limit', upper_limit: upper_date_limit)
  end

  def cumulative_flow_for_date(demands_ids, start_date, end_date, stream)
    demands = Demand.story.joins(demand_transitions: :stage)
                    .where(id: demands_ids)
                    .where('demands.discarded_at IS NULL OR demands.discarded_at > :end_date', end_date: end_date)
                    .where('(demands.end_date IS NULL OR demands.end_date >= :start_date)', start_date: start_date)
                    .where('stages.stage_stream = :stream', stream: Stage.stage_streams[stream])
                    .where('stages.stage_stream <> :stream', stream: Stage.stage_streams[:out_stream])

    stages_id = demands.select('stages.id AS stage_id').map(&:stage_id).uniq
    stages = Stage.where(id: stages_id).order('stages.order DESC')

    build_cumulative_stage_hash(end_date, demands, stages)
  end

  def total_time_for(projects, sum_field, group_field_year_period)
    result_array = mount_select_to_total_time_group(group_field_year_period, sum_field)
                   .finished_in_downstream
                   .where(project_id: projects.map(&:id))

    grouped_result = mount_group_by_time(group_field_year_period, result_array)

    build_hash_to_total_duration_query_result(grouped_result, group_field_year_period)
  end

  def discarded_demands_to_projects(projects)
    Demand.where(project_id: projects.map(&:id)).where('discarded_at IS NOT NULL').order(discarded_at: :desc)
  end

  private

  def mount_select_to_total_time_group(group_field_year_period, sum_field)
    if group_field_year_period == 'day'
      Demand.kept.select('end_date AS sum_date_period', "SUM(#{sum_field}) AS total_time")
    else
      Demand.kept.select("EXTRACT(#{group_field_year_period} FROM end_date) AS sum_group_period", 'EXTRACT(YEAR FROM end_date) AS sum_year', "SUM(#{sum_field}) AS total_time")
    end
  end

  def mount_group_by_time(group_field_year_period, query)
    if group_field_year_period == 'day'
      query.group('sum_date_period')
    else
      query.group('sum_group_period', 'sum_year')
    end
  end

  def build_cumulative_stage_hash(analysed_date, demands, stages)
    acc_count = 0
    cumulative_hash = {}
    stages.each do |stage|
      stage_demands_count = demands.where('demand_transitions.last_time_in <= :limit_date', limit_date: analysed_date).where('stages.id = :stage_id', stage_id: stage.id).uniq.count
      stage_result = stage_demands_count - acc_count
      cumulative_hash[stage.name] = stage_result
      acc_count += stage_result
    end

    cumulative_hash.to_a.reverse.to_h
  end

  def demands_stories_to_projects(projects)
    Demand.kept.story.where(project_id: projects.map(&:id))
  end

  def demands_list_to_projects(projects)
    DemandsList.story.where(project_id: projects.map(&:id))
  end

  def demands_for_projects_finished_in_period(projects, start_period, end_period)
    Demand.kept.story.where(project_id: projects).where('end_date BETWEEN :start_period AND :end_period', start_period: start_period, end_period: end_period)
  end

  def demands_for_projects_and_finished_until_limit_date(projects, limit_date)
    Demand.kept.story.where(project_id: projects).where('end_date <= :limit_date', limit_date: limit_date)
  end

  def build_hash_to_total_duration_query_result(query_result_array, group_period)
    query_result_hash = {}

    if group_period == 'day'
      query_result_array.each { |group_sum| query_result_hash[group_sum.sum_date_period.to_date.to_s] = group_sum.total_time.to_f }
    else
      query_result_array.each { |group_sum| query_result_hash[[group_sum.sum_group_period.to_i, group_sum.sum_year.to_i]] = group_sum.total_time.to_f }
    end

    query_result_hash
  end
end
