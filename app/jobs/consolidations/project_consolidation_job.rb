# frozen_string_literal: true

module Consolidations
  class ProjectConsolidationJob < ApplicationJob
    queue_as :consolidations

    def perform(project, cache_date = Time.zone.today)
      end_of_day = cache_date.end_of_day

      demands = project.demands.where('demands.created_date <= :limit_date', limit_date: end_of_day)
      demands_finished = demands.not_discarded_until(end_of_day).finished_until_date(end_of_day).order(end_date: :asc)
      demands_discarded = demands.where('discarded_at <= :limit_date', limit_date: end_of_day)
      start_date = cache_date.beginning_of_month
      demands_finished_in_month = project.demands.to_end_dates(start_date, cache_date)
      demands_lead_time = demands_finished.map(&:leadtime).flatten.compact
      demands_lead_time_in_month = demands_finished_in_month.map(&:leadtime).flatten.compact

      demand_efforts_manual = demands.where(manual_effort: true)
      demand_efforts_manual_upstream = demand_efforts_manual.sum(&:effort_upstream)
      demand_efforts_manual_downstream = demand_efforts_manual.sum(&:effort_downstream)

      demands_ids_to_efforts = (demands.map(&:id) + demands_discarded.map(&:id)) - demand_efforts_manual.map(&:id)
      demand_efforts = DemandEffort.where(demand_id: demands_ids_to_efforts).to_dates(start_date, cache_date)
      demand_efforts_accumulated = DemandEffort.where(demand_id: demands_ids_to_efforts).until_date(cache_date)

      lead_time_histogram_data = Stats::StatisticsService.instance.leadtime_histogram_hash(demands_lead_time)
      lead_time_histogram_bins = lead_time_histogram_data.keys

      data_start_date = 12.weeks.ago

      consolidation_period_for_montecarlo = TimeService.instance.weeks_between_of(data_start_date.end_of_week, cache_date.end_of_week)

      team = project.team

      project_work_item_flow_information = Flow::WorkItemFlowInformations.new(project.demands, project.initial_scope, consolidation_period_for_montecarlo.length, consolidation_period_for_montecarlo.last, 'week')
      team_work_item_flow_information = Flow::WorkItemFlowInformations.new(team.demands, team.projects.map(&:initial_scope).compact.sum, consolidation_period_for_montecarlo.length, consolidation_period_for_montecarlo.last, 'week')

      consolidation_period_for_montecarlo.each_with_index do |analysed_date, distribution_index|
        project_work_item_flow_information.work_items_flow_behaviour(consolidation_period_for_montecarlo.first, analysed_date, distribution_index, true)
        team_work_item_flow_information.work_items_flow_behaviour(consolidation_period_for_montecarlo.first, analysed_date, distribution_index, true)
      end

      project_based_montecarlo_durations = Stats::StatisticsService.instance.run_montecarlo(project.remaining_work(end_of_day), project_work_item_flow_information.throughput_array_for_monte_carlo.last(12), 500)
      team_based_montecarlo_durations = compute_team_monte_carlo_weeks(end_of_day, project, team_work_item_flow_information.throughput_per_period.last(12))

      weeks_by_little_law = 0
      project_remaining_backlog = project.remaining_backlog
      throughput_average = Stats::StatisticsService.instance.population_average(project_work_item_flow_information.throughput_per_period, 8)
      weeks_by_little_law = project_remaining_backlog.to_f / throughput_average unless project_remaining_backlog.zero? || throughput_average.zero?

      code_needed_blocks_count = 0
      code_needed_blocks_per_demand = 0

      if demands_finished.count.positive?
        code_needed_blocks_count = demands_finished.map { |demand| demand.demand_blocks.coding_needed.count }.sum
        code_needed_blocks_per_demand = code_needed_blocks_count.to_f / demands_finished.count
      end

      tasks = project.tasks.where('tasks.created_date <= :limit_date', limit_date: end_of_day)
      tasks_finished = Task.where(id: project.tasks.where('tasks.end_date <= :limit_date', limit_date: end_of_day).order('tasks.end_date').map(&:id))
      tasks_not_finished = tasks - tasks_finished
      tasks_throughputs = tasks_finished.group('EXTRACT(week FROM tasks.end_date)').group('EXTRACT(isoyear FROM tasks.end_date)').count

      tasks_based_montecarlo_durations = Stats::StatisticsService.instance.run_montecarlo(tasks_not_finished.count, tasks_throughputs.values.last(12), 500)

      consolidation = Consolidations::ProjectConsolidation.where(project: project, consolidation_date: cache_date).first_or_create
      consolidation.update(last_data_in_week: (cache_date.to_date) == (cache_date.to_date.end_of_week),
                           last_data_in_month: (cache_date.to_date) == (cache_date.to_date.end_of_month),
                           last_data_in_year: (cache_date.to_date) == (cache_date.to_date.end_of_year),
                           wip_limit: project.max_work_in_progress,
                           current_wip: demands.not_discarded_until(end_of_day).in_wip(end_of_day),
                           demands_ids: demands.map(&:id),
                           demands_finished_ids: demands_finished.map(&:id),
                           project_throughput: demands_finished.count,
                           project_quality: project.quality(cache_date),
                           lead_time_min: demands_lead_time.min,
                           lead_time_max: demands_lead_time.max,
                           lead_time_p25: Stats::StatisticsService.instance.percentile(25, demands_lead_time),
                           lead_time_p65: Stats::StatisticsService.instance.percentile(65, demands_lead_time),
                           lead_time_p75: Stats::StatisticsService.instance.percentile(75, demands_lead_time),
                           lead_time_p80: Stats::StatisticsService.instance.percentile(80, demands_lead_time),
                           lead_time_p95: Stats::StatisticsService.instance.percentile(95, demands_lead_time),
                           lead_time_average: Stats::StatisticsService.instance.mean(demands_lead_time),
                           lead_time_std_dev: Stats::StatisticsService.instance.standard_deviation(demands_lead_time),
                           lead_time_histogram_bin_min: lead_time_histogram_bins.min,
                           lead_time_histogram_bin_max: lead_time_histogram_bins.max,
                           lead_time_min_month: demands_lead_time_in_month.min,
                           lead_time_max_month: demands_lead_time_in_month.max,
                           lead_time_p80_month: Stats::StatisticsService.instance.percentile(80, demands_lead_time_in_month),
                           lead_time_std_dev_month: Stats::StatisticsService.instance.standard_deviation(demands_lead_time_in_month),
                           monte_carlo_weeks_min: project_based_montecarlo_durations.min,
                           monte_carlo_weeks_max: project_based_montecarlo_durations.max,
                           monte_carlo_weeks_std_dev: Stats::StatisticsService.instance.standard_deviation(project_based_montecarlo_durations),
                           monte_carlo_weeks_p80: Stats::StatisticsService.instance.percentile(80, project_based_montecarlo_durations),
                           team_based_monte_carlo_weeks_min: team_based_montecarlo_durations.min,
                           team_based_monte_carlo_weeks_max: team_based_montecarlo_durations.max,
                           team_based_monte_carlo_weeks_std_dev: Stats::StatisticsService.instance.standard_deviation(team_based_montecarlo_durations),
                           team_based_monte_carlo_weeks_p80: Stats::StatisticsService.instance.percentile(80, team_based_montecarlo_durations),
                           operational_risk: 1 - Stats::StatisticsService.instance.compute_odds_to_deadline(project.remaining_weeks(end_of_day.to_date), project_based_montecarlo_durations),
                           project_scope: project.backlog_count_for(end_of_day),
                           flow_pressure: project.flow_pressure(end_of_day),
                           value_per_demand: project.value_per_demand,
                           team_based_operational_risk: 1 - Stats::StatisticsService.instance.compute_odds_to_deadline(project.remaining_weeks(end_of_day.to_date), team_based_montecarlo_durations),
                           weeks_by_little_law: weeks_by_little_law,
                           hours_per_demand: DemandService.instance.hours_per_demand(demands_finished),
                           hours_per_demand_month: DemandService.instance.hours_per_demand(demands_finished_in_month),
                           flow_efficiency: DemandService.instance.flow_efficiency(demands_finished),
                           flow_efficiency_month: DemandService.instance.flow_efficiency(demands_finished_in_month),
                           bugs_opened: demands.bug.count,
                           bugs_closed: demands_finished.bug.count,
                           code_needed_blocks_count: code_needed_blocks_count,
                           code_needed_blocks_per_demand: code_needed_blocks_per_demand,
                           project_scope_hours: project.qty_hours,
                           project_throughput_hours: demand_efforts_accumulated.sum(&:effort_value) + demand_efforts_manual_upstream + demand_efforts_manual_downstream,
                           project_throughput_hours_upstream: demand_efforts_accumulated.upstream_efforts.sum(&:effort_value) + demand_efforts_manual_upstream,
                           project_throughput_hours_downstream: demand_efforts_accumulated.downstream_efforts.sum(&:effort_value) + demand_efforts_manual_downstream,
                           project_throughput_hours_in_month: demand_efforts.sum(&:effort_value) + demands_finished_in_month.sum(&:total_effort),
                           project_throughput_hours_upstream_in_month: demand_efforts.upstream_efforts.sum(&:effort_value) + demands_finished_in_month.sum(&:effort_upstream),
                           project_throughput_hours_downstream_in_month: demand_efforts.downstream_efforts.sum(&:effort_value) + demands_finished_in_month.sum(&:effort_downstream),
                           project_throughput_hours_development: demand_efforts_accumulated.developer_efforts.sum(&:effort_value),
                           project_throughput_hours_design: demand_efforts_accumulated.designer_efforts.sum(&:effort_value),
                           project_throughput_hours_management: demand_efforts_accumulated.manager_efforts.sum(&:effort_value),
                           project_throughput_hours_development_in_month: demand_efforts.developer_efforts.sum(&:effort_value),
                           project_throughput_hours_design_in_month: demand_efforts.designer_efforts.sum(&:effort_value),
                           project_throughput_hours_management_in_month: demand_efforts.manager_efforts.sum(&:effort_value),
                           tasks_based_deadline_p80: Stats::StatisticsService.instance.percentile(80, tasks_based_montecarlo_durations),
                           tasks_based_operational_risk: 1 - Stats::StatisticsService.instance.compute_odds_to_deadline(project.remaining_weeks(end_of_day.to_date), tasks_based_montecarlo_durations)
      )
    end

    private

    def compute_team_monte_carlo_weeks(limit_date, project, team_throughput_data)
      team = project.team

      project_wip = project.max_work_in_progress
      team_wip = team.max_work_in_progress
      project_share_in_team_flow = 1
      project_share_in_team_flow = (project_wip.to_f / team_wip.to_f) if team_wip.positive? && project_wip.positive?

      project_share_team_throughput_data = team_throughput_data.map { |throughput| throughput * project_share_in_team_flow }
      Stats::StatisticsService.instance.run_montecarlo(project.remaining_work(limit_date), project_share_team_throughput_data, 500)
    end
  end
end
