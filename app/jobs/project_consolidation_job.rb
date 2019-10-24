class ProjectConsolidationJob < ApplicationJob
  queue_as :default

  def perform(project)
    min_date = project.start_date
    start_date = project.start_date
    end_date = [project.end_date, Time.zone.today.end_of_week].min

    while start_date <= end_date
      beginning_of_week = start_date.beginning_of_week
      end_of_week = start_date.end_of_week

      demands = project.demands.kept.where('demands.created_date <= :analysed_date', analysed_date: end_of_week)
      demands_finished = demands.finished_with_leadtime.where('demands.end_date <= :analysed_date', analysed_date: end_of_week).order(end_date: :asc)
      demands_finished_in_week = demands.finished_with_leadtime.to_end_dates(beginning_of_week, end_of_week).order(end_date: :asc)

      team = project.team

      x_axis = TimeService.instance.weeks_between_of(min_date.end_of_week, start_date.end_of_week)

      products_in_project = project.products
      start_date_to_product = Project.where(id: products_in_project.map { |product| product.projects.map(&:id) }.flatten).map(&:start_date).compact.min || project.start_date

      team_product_demands = DemandsRepository.instance.throughput_to_products_team_and_period(products_in_project, team, start_date_to_product, end_of_week)

      project_work_item_flow_information = Flow::WorkItemFlowInformations.new(x_axis, min_date, end_of_week, project.demands, team.projects.map(&:initial_scope).compact.sum)
      team_work_item_flow_information = Flow::WorkItemFlowInformations.new(x_axis, min_date, end_of_week, team.demands, team.projects.map(&:initial_scope).compact.sum)
      product_work_item_flow_information = Flow::WorkItemFlowInformations.new(x_axis, min_date, end_of_week, team_product_demands, team.projects.map(&:initial_scope).compact.sum)
      product_throughput_data = product_work_item_flow_information.throughput_per_period.select(&:positive?)

      project_based_montecarlo_durations = Stats::StatisticsService.instance.run_montecarlo(project.remaining_backlog(end_of_week), project_work_item_flow_information.throughput_per_period.last(20), 500)
      product_based_montecarlo_durations = Stats::StatisticsService.instance.run_montecarlo(project.remaining_backlog(end_of_week), product_throughput_data.last(20), 500)
      team_based_montecarlo_durations = compute_team_monte_carlo_weeks(end_of_week, project, team_work_item_flow_information.throughput_per_period.last(20))

      consolidation = ProjectConsolidation.find_or_initialize_by(project: project, consolidation_date: end_of_week)
      consolidation.update(population_start_date: demands.minimum(:created_date),
                           population_end_date: demands.maximum(:end_date),
                           wip_limit: project.max_work_in_progress,
                           current_wip: compute_current_wip(beginning_of_week, end_of_week, demands),
                           demands_ids: demands.map(&:id),
                           demands_finished_ids: demands_finished.map(&:id),
                           demands_lead_times: demands_finished.map(&:leadtime),
                           demands_finished_in_week: demands_finished_in_week.map(&:id),
                           lead_time_in_week: demands_finished_in_week.map(&:leadtime),
                           project_weekly_throughput: project_work_item_flow_information.throughput_per_period,
                           team_weekly_throughput: team_work_item_flow_information.throughput_per_period,
                           products_weekly_throughput: product_throughput_data,
                           project_monte_carlo_weeks: project_based_montecarlo_durations,
                           products_monte_carlo_weeks: product_based_montecarlo_durations,
                           team_monte_carlo_weeks: team_based_montecarlo_durations)

      start_date += 1.week
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

  def compute_team_monte_carlo_weeks(limit_date, project, team_throughput_data)
    team = project.team

    project_wip = project.max_work_in_progress
    team_wip = team.max_work_in_progress
    project_share_in_flow = 1
    project_share_in_flow = (project_wip.to_f / team_wip.to_f) if team_wip.positive? && project_wip.positive?

    project_share_team_throughput_data = team_throughput_data.map { |throughput| throughput * project_share_in_flow }
    Stats::StatisticsService.instance.run_montecarlo(project.remaining_backlog(limit_date), project_share_team_throughput_data, 500)
  end
end
