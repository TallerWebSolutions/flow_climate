# frozen_string_literal: true

class DemandService
  include Singleton

  def quantitative_consolidation_per_week_to_projects(projects)
    start_date = projects.map(&:start_date).min
    end_date = [projects.map(&:end_date).max, Time.zone.today].min

    weeks_array = TimeService.instance.weeks_between_of(start_date, end_date)

    behaviour_data = {}

    arrived_in_week_array = []
    throughput_in_week_array = []

    weeks_array.sort.reverse_each do |week_year|
      behaviour_data = behaviour_data.merge(build_arrival_departure_hash(week_year, projects, arrived_in_week_array, throughput_in_week_array))
    end

    behaviour_data
  end

  private

  def build_arrival_departure_hash(week_year, projects, arrived_in_week_array, throughput_in_week_array)
    behaviour_data = {}
    arrived_in_week = DemandsRepository.instance.committed_demands_by_project_and_week(projects, week_year.cweek, week_year.cwyear)
    arrived_in_week_array << arrived_in_week.count
    throughput_week = DemandsRepository.instance.throughput_by_project_and_week(projects, week_year.beginning_of_week, week_year.end_of_week)
    throughput_in_week_array << throughput_week.count
    behaviour_data[week_year] = { arrived_in_week: arrived_in_week, std_dev_arrived: Stats::StatisticsService.instance.standard_deviation(arrived_in_week_array), throughput_in_week: throughput_week, std_dev_throughput: Stats::StatisticsService.instance.standard_deviation(throughput_in_week_array) }
    behaviour_data
  end
end
