# frozen_string_literal: true

class ProjectsRepository
  include Singleton

  def active_projects_in_month(projects, required_date)
    where_by_start_end_dates(projects.joins(:customer).active, required_date)
  end

  def hours_consumed_per_month(projects, required_date)
    active_projects = active_projects_in_month(projects, required_date)
    total_consumed = 0
    active_projects.each { |project| total_consumed += project.demands.finished_in_month(required_date.to_date.month, required_date.to_date.year).sum(&:total_effort) }
    total_consumed
  end

  def hours_consumed_per_week(projects, required_date)
    active_projects = active_projects_in_month(projects, required_date)
    total_consumed = 0
    active_projects.each { |project| total_consumed += project.demands.finished_in_week(required_date.cweek, required_date.cwyear).sum(&:total_effort) }
    total_consumed
  end

  def flow_pressure_to_month(projects, required_date)
    active_projects = active_projects_in_month(projects, required_date)
    total_flow_pressure = 0
    active_projects.each { |project| total_flow_pressure += project.flow_pressure }
    total_flow_pressure
  end

  def money_to_month(projects, required_date)
    active_projects_in_month(projects, required_date).sum(&:money_per_month)
  end

  def all_projects_for_team(team)
    Project.where('projects.team_id = :team_id', team_id: team.id).includes(:team).includes(:product).includes(:customer).order(end_date: :desc)
  end

  def add_query_to_projects_in_status(projects, status_param)
    projects_with_query_and_order = projects
    projects_with_query_and_order = projects.where(status: status_param) if status_param != 'all'
    projects_with_query_and_order.order(end_date: :desc)
  end

  def projects_ending_after(projects, limit_date)
    projects.where('end_date >= :limit_date', limit_date: limit_date)
  end

  def finish_project!(project)
    project.demands.not_finished.each { |demand| demand.update(end_date: Time.zone.now) }
    project.update(status: :finished)
  end

  private

  def where_by_start_end_dates(projects, required_date)
    projects.where('(start_date <= :end_date AND end_date >= :start_date) OR (start_date >= :start_date AND end_date <= :end_date) OR (start_date <= :end_date AND start_date >= :start_date)', start_date: required_date.beginning_of_month, end_date: required_date.end_of_month)
  end
end
