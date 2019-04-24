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

      compute_percentile(desired_percentile, processed_population).to_f
    end

    def mean(population_array)
      population_array.sum.to_f / population_array.count.to_f
    end

    def mode(population_array)
      return nil if population_array.blank?

      population_array.group_by { |e| e }.max_by { |_k, v| v.length }.first
    end

    def leadtime_histogram_hash(leadtime_data_array)
      create_histogram_data(leadtime_data_array)
    end

    def throughput_histogram_hash(throughput_data_array)
      create_histogram_data(throughput_data_array)
    end

    def run_montecarlo(remaining_backlog_count, throughput_data_array, qty_cycles)
      compute_durations_array(remaining_backlog_count, throughput_data_array, qty_cycles)
    end

    def compute_percentage(data_count_analysed, data_count_remaining)
      return 0 if data_count_remaining.zero? && data_count_analysed.zero?

      (data_count_analysed.to_f / (data_count_analysed.to_f + data_count_remaining.to_f) * 100)
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
        begin
          delivered_per_week = throughput_data_array.sample
          remaining_backlog_simulated -= delivered_per_week
          duration += 1
        end
      end
      duration
    end

    def compute_percentile(desired_percentile, population)
      rank = desired_percentile / 100.0 * (population.size - 1)
      lower, upper = population[rank.floor, 2]
      lower + (upper - lower) * (rank - rank.floor)
    end

    def variance(population_array)
      return 0 if population_array.size == 1

      mean = population_array.sum / population_array.count.to_f
      sum = population_array.inject(0) { |accum, i| accum + (i - mean)**2 }
      sum / (population_array.length - 1).to_f
    end
  end
end
