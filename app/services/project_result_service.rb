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

    update_results_cascading!(new_result, old_result)
    save_monte_carlo_date!(new_result.reload, 100)

    new_result.reload
  end

  private

  def update_results_cascading!(new_result, old_result)
    bottom_limit_to_update_result = new_result.result_date
    bottom_limit_to_update_result = [new_result.result_date, old_result.result_date].min if old_result.present?

    results_to_update = ProjectResult.where('result_date >= :new_result_date', new_result_date: bottom_limit_to_update_result)
    results_to_update.map(&:compute_flow_metrics!)

    ProjectResult.reset_counters(new_result.id, :demands_count)
    ProjectResult.reset_counters(old_result.id, :demands_count) if old_result.present? && old_result.persisted?
  end

  def define_initial_attributes!(team, demand, project_result)
    project_result.update(cost_in_month: team.active_monthly_cost_for_billable_types([demand.project.project_type]),
                          available_hours: team.active_monthly_available_hours_for_billable_types([demand.project.project_type]))
  end

  def save_monte_carlo_date!(project_result, qty_cycles)
    monte_carlo_data = Stats::StatisticsService.instance.run_montecarlo(project_result.project.demands.count,
                                                                        ProjectsRepository.instance.leadtime_per_week([project_result.project]).values,
                                                                        ProjectsRepository.instance.throughput_per_week([project_result.project]).values,
                                                                        qty_cycles)
    project_result.update(monte_carlo_date: monte_carlo_data.monte_carlo_date_hash.keys.first)
  end
end
