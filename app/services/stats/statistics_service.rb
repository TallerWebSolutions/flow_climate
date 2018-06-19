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

    def run_montecarlo(remaining_backlog_count, leadtime_histogram_data_array, throughput_histogram_data, qty_cycles)
      dates_and_hits_hash = compute_probability_of_dates(remaining_backlog_count, leadtime_histogram_data_array, throughput_histogram_data, qty_cycles)
      Presenter::MonteCarloPresenter.new(dates_and_hits_hash)
    end

    def compute_percentage(data_count_analysed, data_count_remaining)
      return 0 if data_count_remaining.zero? && data_count_analysed.zero?
      (data_count_analysed.to_f / (data_count_analysed.to_f + data_count_remaining.to_f) * 100)
    end

    private

    def create_histogram_data(data_array)
      intervals = Math.sqrt(data_array.length).round
      bins, frequencies = data_array.histogram(intervals, min: data_array.min, max: data_array.max)
      histogram_data = {}
      bins.each_with_index { |bin, index| histogram_data[bin] = frequencies[index] }
      histogram_data
    end

    def compute_probability_of_dates(remaining_backlog_count, leadtime_histogram_data_array, throughput_histogram_data, qty_cycles)
      date_hits_hash = {}
      qty_cycles.times do
        new_prediction = run_montecarlo_cycle(remaining_backlog_count, leadtime_histogram_data_array, throughput_histogram_data)
        date_hits_hash[new_prediction.beginning_of_day.to_i] = date_frequency(date_hits_hash, new_prediction)
      end

      date_hits_hash
    end

    def run_montecarlo_cycle(remaining_backlog_count, leadtime_histogram_data_array, throughput_histogram_data_array)
      new_prediction_interval = 0
      remaining_backlog_count.times do
        chosen_value = choose_weighted(create_histogram_data(leadtime_histogram_data_array))
        new_prediction_interval += chosen_value / 86_400 if chosen_value.positive?
      end
      slots_for_paralelism = choose_weighted(create_histogram_data(throughput_histogram_data_array))
      slots_for_paralelism = 1 unless slots_for_paralelism.positive?
      TimeService.instance.skip_weekends(Time.zone.today, new_prediction_interval / slots_for_paralelism)
    end

    def compute_percentile(desired_percentile, population)
      rank = desired_percentile / 100.0 * (population.size - 1)
      lower, upper = population[rank.floor, 2]
      lower + (upper - lower) * (rank - rank.floor)
    end

    def choose_weighted(weighted_distribution)
      current = 0
      max = weighted_distribution.values.sum

      random_value = rand(max) + 1
      weighted_distribution.each do |key, val|
        current += val
        return key if random_value <= current
      end

      0
    end

    def date_frequency(date_hits_hash, new_prediction)
      return date_hits_hash[new_prediction.beginning_of_day.to_i] + 1 if date_hits_hash.key?(new_prediction.beginning_of_day.to_i)
      1
    end
  end
end
