# frozen_string_literal: true

class ProjectResultService
  include Singleton

  def compute_demand!(team, demand)
    old_result = demand.project_result
    old_result.remove_demand!(demand) if old_result.present?

    new_result_date = (demand.end_date || demand.created_date).to_date
    new_result = ProjectResult.where(team: team, project: demand.project, result_date: new_result_date).first_or_initialize
    complete_new_result = define_initial_attributes_for_result!(team, demand, new_result, new_result_date)

    return complete_new_result unless complete_new_result.save

    update_results_cascading!(complete_new_result, old_result, demand.project.start_date)

    demand.project.update_team_in_product(team)

    complete_new_result.reload
  end

  private

  def define_initial_attributes_for_result!(team, demand, project_result, result_date)
    completed_result = project_result.clone
    completed_result.update(result_date: result_date, project: demand.project, team: team)

    available_hours = team.active_daily_available_hours_for_billable_types([demand.project.project_type])
    team_cost_in_month = ProjectFinancesService.instance.compute_cost_for_average_demand_cost(demand.project, result_date)
    effort_share_in_month = ProjectFinancesService.instance.effort_share_in_month(demand.project, result_date)

    completed_result.update(result_date: result_date, cost_in_month: team_cost_in_month, available_hours: available_hours, effort_share_in_month: effort_share_in_month)
    completed_result.compute_flow_metrics!

    completed_result.add_demand!(demand)

    completed_result
  end

  # TODO: lot of reponsabilities here
  def update_results_cascading!(new_result, old_result, limit_date)
    bottom_limit_to_update_result = new_result.result_date
    bottom_limit_to_update_result = [new_result.result_date, old_result.result_date].min if old_result.present?

    results_to_update = ProjectResult.where('result_date >= :new_result_date', new_result_date: bottom_limit_to_update_result)
    results_to_update.map(&:compute_flow_metrics!)

    save_monte_carlo_date!(new_result.reload, 100, limit_date)
  end

  def save_monte_carlo_date!(project_result, qty_cycles, limit_date)
    montecarlo_durations = Stats::StatisticsService.instance.run_montecarlo(project_result.project.demands.count,
                                                                            ProjectsRepository.instance.throughput_per_week([project_result.project], limit_date).values,
                                                                            qty_cycles)
    confidence_80_duration = Stats::StatisticsService.instance.percentile(80, montecarlo_durations)
    date_with_80_percentile = Time.zone.today + confidence_80_duration.weeks
    project_result.update(monte_carlo_date: date_with_80_percentile)
  end
end
