# frozen_string_literal: true

class ProjectResultService
  include Singleton

  def compute_demand!(team, demand)
    old_result = demand.project_result
    old_result.remove_demand!(demand) if old_result.present?

    new_result_date = (demand.end_date || demand.created_date).to_date
    new_result = ProjectResult.where(team: team, project: demand.project, result_date: new_result_date).first_or_create
    define_initial_attributes!(team, demand, new_result)
    new_result.add_demand!(demand)

    return new_result unless new_result.save

    update_results_cascading!(new_result, old_result, demand.project.start_date)

    demand.project.update_team_in_product(team)

    new_result.reload
  end

  private

  def define_initial_attributes!(team, demand, project_result)
    available_hours = team.active_daily_available_hours_for_billable_types([demand.project.project_type])
    team_cost_in_month = ProjectFinancesService.instance.compute_cost_for_average_demand_cost(demand.project, project_result.result_date)
    effort_share_in_month = ProjectFinancesService.instance.effort_share_in_month(demand.project, project_result.result_date)

    project_result.update(cost_in_month: team_cost_in_month, available_hours: available_hours, effort_share_in_month: effort_share_in_month)
  end

  # TODO: lot of reponsabilities here
  def update_results_cascading!(new_result, old_result, limit_date)
    bottom_limit_to_update_result = new_result.result_date
    bottom_limit_to_update_result = [new_result.result_date, old_result.result_date].min if old_result.present?

    results_to_update = ProjectResult.where('result_date >= :new_result_date', new_result_date: bottom_limit_to_update_result)
    results_to_update.map(&:compute_flow_metrics!)

    save_monte_carlo_date!(new_result.reload, 100, limit_date)

    ProjectResult.reset_counters(new_result.id, :demands_count) if new_result.present? && new_result.persisted?
    ProjectResult.reset_counters(old_result.id, :demands_count) if old_result.present? && old_result.persisted?
  end

  def save_monte_carlo_date!(project_result, qty_cycles, limit_date)
    monte_carlo_data = Stats::StatisticsService.instance.run_montecarlo(project_result.project.demands.count,
                                                                        ProjectsRepository.instance.leadtime_per_week([project_result.project], limit_date).values,
                                                                        ProjectsRepository.instance.throughput_per_week([project_result.project], limit_date).values,
                                                                        qty_cycles)
    project_result.update(monte_carlo_date: monte_carlo_data.monte_carlo_date_hash.keys.first)
  end
end
