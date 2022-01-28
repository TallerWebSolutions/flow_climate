# frozen_string_literal: true

module Consolidations
  class InitiativeConsolidationJob < ApplicationJob
    queue_as :consolidations

    def perform(initiative, cache_date = Time.zone.today)
      end_of_day = cache_date.end_of_day

      tasks = initiative.tasks.where('tasks.created_date <= :analysed_date', analysed_date: end_of_day)
      tasks_finished = tasks.finished(end_of_day)
      tasks_finished_in_month = tasks_finished.where('tasks.end_date BETWEEN :upper_limit AND :bottom_limit', upper_limit: cache_date.beginning_of_month, bottom_limit: cache_date)
      tasks_finished_in_week = tasks_finished.where('tasks.end_date BETWEEN :upper_limit AND :bottom_limit', upper_limit: cache_date.beginning_of_week, bottom_limit: cache_date)
      tasks_not_finished = tasks - tasks_finished

      tasks_completion_time = tasks_finished.map(&:seconds_to_complete).flatten.compact
      tasks_completion_time_month = tasks_finished_in_month.map(&:seconds_to_complete).flatten.compact
      tasks_completion_time_week = tasks_finished_in_week.map(&:seconds_to_complete).flatten.compact

      tasks_completion_time_P80 = Stats::StatisticsService.instance.percentile(80, tasks_completion_time)
      tasks_completion_time_in_month_P80 = Stats::StatisticsService.instance.percentile(80, tasks_completion_time_month)
      tasks_completion_time_in_week_P80 = Stats::StatisticsService.instance.percentile(80, tasks_completion_time_week)

      tasks_throughputs = Task.where(id: tasks_finished.map(&:id)).group('EXTRACT(week FROM tasks.end_date)').group('EXTRACT(isoyear FROM tasks.end_date)').count

      tasks_based_montecarlo_durations = Stats::StatisticsService.instance.run_montecarlo(tasks_not_finished.count, tasks_throughputs.values.last(12), 500)

      consolidation = Consolidations::InitiativeConsolidation.where(initiative: initiative, consolidation_date: cache_date).first_or_initialize
      consolidation.update(consolidation_date: cache_date,
                           last_data_in_week: (cache_date.to_date) == (cache_date.to_date.end_of_week),
                           last_data_in_month: (cache_date.to_date) == (cache_date.to_date.end_of_month),
                           last_data_in_year: (cache_date.to_date) == (cache_date.to_date.end_of_year),
                           tasks_completion_time_p80: tasks_completion_time_P80,
                           tasks_completion_time_p80_in_week: tasks_completion_time_in_week_P80,
                           tasks_completion_time_p80_in_month: tasks_completion_time_in_month_P80,
                           tasks_delivered: tasks_finished,
                           tasks_delivered_in_week: tasks_finished_in_week,
                           tasks_delivered_in_month: tasks_finished_in_month,
                           tasks_operational_risk: 1 - Stats::StatisticsService.instance.compute_odds_to_deadline(initiative.remaining_weeks(end_of_day.to_date), tasks_based_montecarlo_durations),
                           tasks_scope: tasks.count
      )

    end
  end
end
