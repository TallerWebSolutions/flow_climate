# frozen_string_literal: true

class ProjectFinancesService
  include Singleton

  def compute_cost_for_average_demand_cost(project, date)
    team = project.current_team
    return 0 if team.blank?

    team.active_monthly_cost_for_billable_types([project.project_type]).to_f * effort_share_in_month(project, date)
  end

  def effort_share_in_month(project, date)
    team = project.current_team
    return 0 if team.blank?

    other_team_projects = team.product_projects - [project]

    total_effort_project = total_effort_to_month([project], date.year, date.month)
    total_effort_other_team_projects = total_effort_to_month(other_team_projects, date.year, date.month)
    Stats::StatisticsService.instance.compute_percentage(total_effort_project, total_effort_other_team_projects) / 100
  end

  private

  def total_effort_to_month(projects, year, month)
    amount_effort_upstream_project = DemandsRepository.instance.grouped_by_effort_upstream_per_month(projects)[[year.to_f, month.to_f]] || 0
    amount_effort_downstream_project = DemandsRepository.instance.grouped_by_effort_downstream_per_month(projects)[[year.to_f, month.to_f]] || 0
    amount_effort_upstream_project + amount_effort_downstream_project
  end
end
