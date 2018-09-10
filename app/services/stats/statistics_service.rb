# frozen_string_literal: true

require 'histogram/array'

module Stats
  class StatisticsService
    include Singleton

    def percentile(desired_percentile, population)
      return 0 if population.empty?
      return population.first if population.size == 1

      population.sort!
      return population.last if desired_percentile == 100

      compute_percentile(desired_percentile, population)
    end

    def mean(population)
      population.sum.to_f / population.count.to_f
    end

    def leadtime_histogram_hash(leadtime_data_array)
      create_histogram_data(leadtime_data_array)
    end

    def throughput_histogram_hash(throughput_data_array)
      create_histogram_data(throughput_data_array)
    end

    def run_montecarlo(remaining_backlog_count, throughput_per_week_histogram_data, qty_cycles)
      compute_durations_in_weeks_array(remaining_backlog_count, throughput_per_week_histogram_data, qty_cycles)
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

    private

    def create_histogram_data(data_array)
      intervals = Math.sqrt(data_array.length).round
      bins, frequencies = data_array.histogram(intervals, min: data_array.min, max: data_array.max)
      histogram_data = {}
      bins.each_with_index { |bin, index| histogram_data[bin] = frequencies[index] }
      histogram_data
    end

    def compute_durations_in_weeks_array(remaining_backlog_count, throughput_histogram_data, qty_cycles)
      return [] if throughput_histogram_data.sum.zero?

      durations_array = []
      qty_cycles.times { durations_array << run_montecarlo_cycle(remaining_backlog_count, throughput_histogram_data) }
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
