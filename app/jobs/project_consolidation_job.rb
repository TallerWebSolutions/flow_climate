class ProjectConsolidationJob < ApplicationJob
  queue_as :default

  def perform
    Company.all.each do |company|
      company.projects.each do |project|
        start_date = project.start_date
        end_date = [project.end_date, 1.week.ago.end_of_week.to_date].min

        while start_date <= end_date
          beginning_of_week = start_date.beginning_of_week
          end_of_week = start_date.end_of_week

          demands = project.demands.kept.where('demands.created_date <= :analysed_date', analysed_date: end_of_week)
          demands_finished = demands.finished_with_leadtime.where('demands.end_date <= :analysed_date', analysed_date: end_of_week).order(end_date: :asc)

          team = project.team
          team_projects = team.projects
          team_projects_running_in_date = team.projects.where('start_date <= :end_date AND end_date > :end_date', end_date: end_of_week)

          total_flow_pressure_in_date = team_projects_running_in_date.sum { |project_running_in_date| project_running_in_date.flow_pressure(end_of_week.end_of_day) }

          minimum_start_date = team_projects.minimum(:start_date)
          team_throughput_data_per_week = DemandsRepository.instance.throughput_to_projects_and_period(team_projects.order(:end_date), minimum_start_date, 1.week.ago.end_of_week).group('EXTRACT(WEEK FROM end_date)', 'EXTRACT(YEAR FROM end_date)').count
          team_throughput_data = DemandInfoDataBuilder.instance.build_data_from_hash_per_week(team_throughput_data_per_week, minimum_start_date, 1.week.ago)

          project_wip = project.max_work_in_progress
          team_wip = team.max_work_in_progress
          project_share_in_flow = 1
          project_share_in_flow = (project_wip.to_f / team_wip.to_f) if team_wip.positive? && project_wip.positive?

          project_share_team_throughput_data = team_throughput_data.values.last(10).map { |throughput| throughput * project_share_in_flow }
          team_based_montecarlo_durations = Stats::StatisticsService.instance.run_montecarlo(project.remaining_backlog(end_of_week), project_share_team_throughput_data, 100)
          team_based_montecarlo_80_percent = Stats::StatisticsService.instance.percentile(80, team_based_montecarlo_durations)

          weeks_to_end_date = project.remaining_weeks(end_of_week)

          project_throughput_data_per_week = DemandsRepository.instance.throughput_to_projects_and_period([project], project.start_date, end_of_week).group('EXTRACT(WEEK FROM end_date)', 'EXTRACT(YEAR FROM end_date)').count
          project_throughput_data = DemandInfoDataBuilder.instance.build_data_from_hash_per_week(project_throughput_data_per_week, project.start_date, end_of_week)

          project_based_montecarlo_durations = Stats::StatisticsService.instance.run_montecarlo(project.remaining_backlog(end_of_week), project_throughput_data.values.last(10), 100)
          project_based_montecarlo_80_percent = Stats::StatisticsService.instance.percentile(80, project_based_montecarlo_durations)

          customer_happiness = 0
          customer_happiness = weeks_to_end_date.to_f / project_based_montecarlo_80_percent.to_f if project_based_montecarlo_80_percent.positive?

          wip_per_day = []
          (beginning_of_week.to_date..end_of_week.to_date).each do |day|
            wip_per_day << demands.where('(demands.commitment_date <= :end_date AND demands.end_date IS NULL) OR (commitment_date <= :start_date AND end_date > :end_date)', start_date: day.beginning_of_day, end_date: day.end_of_day).count
          end

          lead_times_array = demands_finished.map { |demand| demand.leadtime.to_f }
          last_8_lead_times = demands_finished.where('end_date >= :limit_date', limit_date: 8.weeks.ago.beginning_of_week).map { |demand| demand.leadtime.to_f }
          last_8_throughputs = project_throughput_data.values.last(8)

          lead_time_p25 = Stats::StatisticsService.instance.percentile(25, lead_times_array)
          lead_time_p75 = Stats::StatisticsService.instance.percentile(75, lead_times_array)

          average_wip_per_day_to_week = 0
          average_wip_per_day_to_week = wip_per_day.compact.sum / wip_per_day.compact.count if wip_per_day.compact.size.positive?

          lead_time_average = 0
          lead_time_average = lead_times_array.compact.sum / lead_times_array.compact.count if lead_times_array.compact.size.positive?

          total_range = 0
          total_range = (last_8_lead_times.max - last_8_lead_times.min) if last_8_lead_times.compact.size.positive?

          lead_time_histogram_data = Stats::StatisticsService.instance.leadtime_histogram_hash(lead_times_array)
          bins = lead_time_histogram_data.keys
          histogram_range = 0
          histogram_range = (bins.last - bins.first) if bins.size.positive?

          average_lead_time = 0
          average_lead_time = (last_8_lead_times.compact.sum / last_8_lead_times.compact.count) if last_8_lead_times.size.positive?

          consolidation = ProjectConsolidation.find_or_initialize_by(project: project, consolidation_date: end_of_week)

          project_flow_pressure_percentage = 0
          project_flow_pressure = project.flow_pressure(end_of_week.end_of_day)
          project_flow_pressure_percentage = project_flow_pressure / total_flow_pressure_in_date if project_flow_pressure.positive? && total_flow_pressure_in_date.positive?

          consolidation.update(customer_happiness: customer_happiness,
                               population_start_date: demands.minimum(:created_date),
                               population_end_date: demands.maximum(:end_date),
                               wip_limit: project_wip,
                               current_wip: average_wip_per_day_to_week,
                               demands_ids: demands.map(&:id),
                               demands_finished_ids: demands_finished.map(&:id),
                               demands_lead_times: demands_finished.map(&:leadtime),
                               demands_lead_times_average: lead_time_average,
                               demands_lead_times_std_dev: Stats::StatisticsService.instance.standard_deviation(lead_times_array),
                               lead_time_max: last_8_lead_times.max,
                               lead_time_min: last_8_lead_times.min,
                               total_range: total_range,
                               histogram_range: histogram_range,
                               lead_time_histogram_bin_max: bins.max,
                               lead_time_histogram_bin_min: bins.min,
                               lead_time_p25: lead_time_p25,
                               lead_time_p75: lead_time_p75,
                               interquartile_range: lead_time_p75 - lead_time_p25,
                               last_lead_time_p80: average_lead_time,
                               last_throughput_per_week_data: last_8_throughputs,
                               project_monte_carlo_weeks_p80: project_based_montecarlo_80_percent,
                               team_monte_carlo_weeks_p80: team_based_montecarlo_80_percent,
                               weeks_to_deadline: weeks_to_end_date,
                               project_aging: (end_of_week - project.start_date),
                               flow_pressure: project_flow_pressure,
                               flow_pressure_percentage: project_flow_pressure_percentage)

          start_date += 1.week
        end
      end
    end
  end
end
