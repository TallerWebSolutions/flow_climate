# frozen_string_literal: true

class DemandService
  include Singleton

  def arrival_and_departure_data_per_week(demands, start_date, end_date)
    weeks_array = TimeService.instance.weeks_between_of(start_date, end_date)

    arrival_and_departure_data = {}

    arrived_in_week_array = []
    throughput_in_week_array = []

    weeks_array.sort.reverse_each do |week_year|
      arrival_and_departure_data = arrival_and_departure_data.merge(build_arrival_departure_hash(week_year, demands, arrived_in_week_array, throughput_in_week_array))
    end

    arrival_and_departure_data
  end

  def lead_time_breakdown(demands)
    transitions_array = demands.map { |demand| demand.demand_transitions.joins(:stage).where(stages: { stage_stream: :downstream, end_point: false }) }.flatten
    transitions_array.sort_by { |transition| transition.stage.order }.group_by { |transition| transition.stage.name }
  end

  private

  def build_arrival_departure_hash(week_year, demands, arrived_in_week_array, throughput_in_week_array)
    behaviour_data = {}
    arrived_in_week = DemandsRepository.instance.committed_demands_to_period(demands, week_year.cweek, week_year.cwyear).order(:end_date)
    arrived_in_week_array << arrived_in_week.count
    throughput_week = DemandsRepository.instance.throughput_to_period(demands, week_year.beginning_of_week, week_year.end_of_week).order(:end_date)
    throughput_in_week_array << throughput_week.count
    behaviour_data[week_year] = { arrived_in_week: arrived_in_week, std_dev_arrived: Stats::StatisticsService.instance.standard_deviation(arrived_in_week_array), throughput_in_week: throughput_week, std_dev_throughput: Stats::StatisticsService.instance.standard_deviation(throughput_in_week_array) }
    behaviour_data
  end
end
