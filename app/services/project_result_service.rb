# frozen_string_literal: true

class ProjectResultService
  include Singleton

  def compute_demand!(team, demand)
    old_result = demand.project_result
    old_result.remove_demand!(demand) if old_result.present?

    new_result_date = (demand.end_date || demand.created_date).to_date
    new_result = ProjectResult.where(team: team, project: demand.project, result_date: new_result_date).first_or_create

    define_initial_attributes(team, demand, new_result)
    new_result.add_demand!(demand)

    results_to_update = ProjectResult.where('result_date >= :new_result_date', new_result_date: new_result_date)
    results_to_update.map(&:compute_flow_metrics!)
  end

  private

  def define_initial_attributes(team, demand, project_result)
    project_result.update(cost_in_month: team.active_monthly_cost_for_billable_types([demand.project.project_type]),
                          available_hours: team.active_monthly_available_hours_for_billable_types([demand.project.project_type]))
  end
end
