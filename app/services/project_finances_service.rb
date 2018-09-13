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

    other_project_in_team = team.product_projects - [project]

    compute_effort_share(date, other_project_in_team, project)
  end

  private

  def compute_effort_share(date, other_project_in_team, project)
    total_effort_project = total_effort_to_month(project.kept_demands_ids, project.start_date, date.year, date.month)
    total_effort_other_team_projects = total_effort_to_month(other_project_in_team.map(&:kept_demands_ids).flatten, other_project_in_team.map(&:start_date).min, date.year, date.month)
    Stats::StatisticsService.instance.compute_percentage(total_effort_project, total_effort_other_team_projects) / 100
  end

  def total_effort_to_month(array_of_demands_ids, start_date, year, month)
    amount_effort_upstream_project = DemandsRepository.instance.grouped_by_effort_upstream_per_month(array_of_demands_ids, start_date)[[year.to_f, month.to_f]] || 0
    amount_effort_downstream_project = DemandsRepository.instance.grouped_by_effort_downstream_per_month(array_of_demands_ids, start_date)[[year.to_f, month.to_f]] || 0
    amount_effort_upstream_project + amount_effort_downstream_project
  end
end
