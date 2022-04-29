# frozen_string_literal: true

require 'histogram/array'

module Stats
  class StatisticsService
    include Singleton

    def percentile(desired_percentile, population)
      processed_population = population.compact
      return 0 if processed_population.empty?
      return processed_population.first.to_f if processed_population.size == 1

      processed_population.sort!
      return processed_population.last.to_f if desired_percentile == 100

      compute_value_in_percentile(desired_percentile, processed_population).to_f
    end

    def percentile_for_lead_time(lead_time, population)
      processed_population = population.compact
      return 0 if processed_population.empty?
      return 1 if processed_population.size == 1

      population_sorted = processed_population.sort
      return 1 if lead_time > population_sorted.max

      below_value = population_sorted.count { |a| a < lead_time }
      below_value / population_sorted.count.to_f
    end

    def mean(population_array)
      population_array.sum.to_f / population_array.count
    end

    def mode(population_array)
      return nil if population_array.blank?

      population_array.group_by { |e| e }.max_by { |_k, v| v.length }.first
    end

    def population_average(population_array, segment_size = 0)
      return 0 unless population_array.count.positive?

      population_segment = population_array
      population_segment = population_array.last(segment_size) if segment_size.positive?

      population_segment.sum.to_f / population_segment.count
    end

    def leadtime_histogram_hash(leadtime_data_array)
      create_histogram_data(leadtime_data_array)
    end

    def completiontime_histogram_hash(completion_time_data_array)
      leadtime_histogram_hash(completion_time_data_array)
    end

    def throughput_histogram_hash(throughput_data_array)
      create_histogram_data(throughput_data_array)
    end

    def run_montecarlo(remaining_backlog_count, throughput_data_array, qty_cycles)
      compute_durations_array(remaining_backlog_count, throughput_data_array, qty_cycles)
    end

    def compute_percentage(amount_analysed, amount_remaining)
      return 0 if amount_remaining.zero? && amount_analysed.zero?

      (amount_analysed.to_f / (amount_analysed.to_f + amount_remaining.to_f) * 100)
    end

    def standard_deviation(population_array)
      Math.sqrt(variance(population_array))
    end

    def tail_events_boundary(population_array)
      return 0 if population_array.blank?

      std_dev = standard_deviation(population_array)
      mean = mean(population_array)
      mean + (4 * std_dev)
    end

    def compute_percentage_variation(initial_value, last_value)
      return 0 if initial_value.blank? || last_value.blank?

      start_value = initial_value
      start_value = 1 if initial_value.zero?
      (last_value.to_f - initial_value.to_f) / start_value.to_f
    end

    def compute_odds_to_deadline(weeks_to_deadline, montecarlo_durations)
      min_weeks_montecarlo = montecarlo_durations.min
      max_weeks_montecarlo = montecarlo_durations.max

      return 0 if min_weeks_montecarlo.blank? || weeks_to_deadline < min_weeks_montecarlo
      return 1 if weeks_to_deadline >= max_weeks_montecarlo

      montecarlo_durations.count { |x| x <= weeks_to_deadline }.to_f / montecarlo_durations.count
    end

    private

    def create_histogram_data(data_array)
      intervals = Math.sqrt(data_array.length).round
      bins, frequencies = data_array.histogram(intervals, min: data_array.min, max: data_array.max)
      histogram_data = {}
      bins.each_with_index { |bin, index| histogram_data[bin] = frequencies[index] }
      histogram_data
    end

    def compute_durations_array(remaining_backlog_count, throughput_data_array, qty_cycles)
      return [] if throughput_data_array.sum.zero?

      durations_array = []
      qty_cycles.times { durations_array << run_montecarlo_cycle(remaining_backlog_count, throughput_data_array) }
      durations_array
    end

    def run_montecarlo_cycle(remaining_backlog_count, throughput_data_array)
      remaining_backlog_simulated = remaining_backlog_count
      duration = 0

      while remaining_backlog_simulated.positive?

        delivered_per_week = throughput_data_array.sample
        remaining_backlog_simulated -= delivered_per_week
        duration += 1

      end
      duration
    end

    def compute_value_in_percentile(desired_percentile, population)
      rank = desired_percentile / 100.0 * (population.size - 1)
      population_slice = population[rank.floor, 2]
      lower = population_slice[0]
      upper = population_slice[1]
      lower + ((upper - lower) * (rank - rank.floor))
    end

    def variance(population_array)
      return 0 if population_array.size == 1

      mean = population_array.sum / population_array.count.to_f
      sum = population_array.inject(0) { |accum, i| accum + ((i - mean)**2) }
      sum / (population_array.length - 1).to_f
    end
  end
end
