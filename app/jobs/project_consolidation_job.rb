class ProjectConsolidationJob < ApplicationJob
  queue_as :default

  def perform
    Company.all.each do |company|
      company.projects.active.each do |project|
        start_date = project.start_date
        end_date = [project.end_date, Time.zone.today.end_of_week].min

        while start_date <= end_date
          beginning_of_week = start_date.beginning_of_week
          end_of_week = start_date.end_of_week

          demands = project.demands.kept.where('demands.created_date <= :analysed_date', analysed_date: end_of_week)
          demands_finished = demands.finished_with_leadtime.where('demands.end_date <= :analysed_date', analysed_date: end_of_week).order(end_date: :asc)

          team_throughput_data = build_team_throughput_data(project)

          project_throughput_data_per_week = DemandsRepository.instance.throughput_to_projects_and_period([project], project.start_date, end_of_week).group('EXTRACT(WEEK FROM end_date)', 'EXTRACT(YEAR FROM end_date)').count
          project_throughput_data = DemandInfoDataBuilder.instance.build_data_from_hash_per_week(project_throughput_data_per_week, project.start_date, end_of_week)
          project_based_montecarlo_durations = Stats::StatisticsService.instance.run_montecarlo(project.remaining_backlog(end_of_week), project_throughput_data.values.last(20), 500)

          projects_in_products = project.products.map(&:projects).flatten.uniq
          start_date_to_product = projects_in_products.map(&:start_date).min || project.start_date

          products_throughput_data_per_week = DemandsRepository.instance.throughput_to_products_and_period(project.products, project.team, start_date_to_product, end_of_week).group('EXTRACT(WEEK FROM end_date)', 'EXTRACT(YEAR FROM end_date)').count
          product_throughput_data = DemandInfoDataBuilder.instance.build_data_from_hash_per_week(products_throughput_data_per_week, projects_in_products.map(&:start_date).min, end_of_week)

          projects_dates_intervals = projects_in_products.map { |project| [project.start_date, project.end_date] }

          product_throughput_data.delete_if { |date_tested, _data| projects_dates_intervals.select { |project_dates| date_tested.between?(project_dates[0], project_dates[1]) }.empty? }

          product_based_montecarlo_durations = Stats::StatisticsService.instance.run_montecarlo(project.remaining_backlog(end_of_week), product_throughput_data.values.last(20), 500)

          consolidation = ProjectConsolidation.find_or_initialize_by(project: project, consolidation_date: end_of_week)
          consolidation.update(population_start_date: demands.minimum(:created_date),
                               population_end_date: demands.maximum(:end_date),
                               wip_limit: project.max_work_in_progress,
                               current_wip: compute_current_wip(beginning_of_week, end_of_week, demands),
                               demands_ids: demands.map(&:id),
                               demands_finished_ids: demands_finished.map(&:id),
                               demands_lead_times: demands_finished.map(&:leadtime),
                               project_weekly_throughput: project_throughput_data.values,
                               team_weekly_throughput: team_throughput_data.values,
                               products_weekly_throughput: product_throughput_data.values,
                               project_monte_carlo_weeks: project_based_montecarlo_durations,
                               products_monte_carlo_weeks: product_based_montecarlo_durations,
                               team_monte_carlo_weeks: compute_team_monte_carlo_weeks(end_of_week, project, team_throughput_data))

          start_date += 1.week
        end
      end
    end
  end

  private

  def compute_current_wip(beginning_of_week, end_of_week, demands)
    wip_per_day = []
    (beginning_of_week.to_date..end_of_week.to_date).each do |day|
      wip_per_day << demands.where('(demands.commitment_date <= :end_date AND demands.end_date IS NULL) OR (commitment_date <= :start_date AND end_date > :end_date)', start_date: day.beginning_of_day, end_date: day.end_of_day).count
    end

    average_wip_per_day_to_week = 0
    average_wip_per_day_to_week = wip_per_day.compact.sum / wip_per_day.compact.count if wip_per_day.compact.size.positive?
    average_wip_per_day_to_week
  end

  def build_team_throughput_data(project)
    team = project.team
    team_projects = team.projects

    minimum_start_date = team_projects.minimum(:start_date)
    team_throughput_data_per_week = DemandsRepository.instance.throughput_to_projects_and_period(team_projects.order(:end_date), minimum_start_date, 1.week.ago.end_of_week).group('EXTRACT(WEEK FROM end_date)', 'EXTRACT(YEAR FROM end_date)').count
    DemandInfoDataBuilder.instance.build_data_from_hash_per_week(team_throughput_data_per_week, minimum_start_date, 1.week.ago)
  end

  def compute_team_monte_carlo_weeks(end_of_week, project, team_throughput_data)
    team = project.team

    project_wip = project.max_work_in_progress
    team_wip = team.max_work_in_progress
    project_share_in_flow = 1
    project_share_in_flow = (project_wip.to_f / team_wip.to_f) if team_wip.positive? && project_wip.positive?

    project_share_team_throughput_data = team_throughput_data.values.last(20).map {|throughput| throughput * project_share_in_flow}
    Stats::StatisticsService.instance.run_montecarlo(project.remaining_backlog(end_of_week), project_share_team_throughput_data, 500)
  end
end
