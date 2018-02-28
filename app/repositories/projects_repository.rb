# frozen_string_literal: true

class ProjectsRepository
  include Singleton

  def active_projects_in_month(projects, required_date)
    where_by_start_end_dates(projects.joins(:customer).active, required_date)
  end

  def hours_consumed_per_month(projects, required_date)
    active_projects = active_projects_in_month(projects, required_date)
    total_consumed = 0
    active_projects.each { |project| total_consumed += project.project_results.in_month(required_date).sum(&:total_hours) }
    total_consumed
  end

  def flow_pressure_to_month(projects, required_date)
    active_projects = active_projects_in_month(projects, required_date)
    total_flow_pressure = 0
    active_projects.each do |project|
      results = project.project_results.in_month(required_date)
      total_flow_pressure += if results.present?
                               results.average(:flow_pressure).to_f
                             elsif required_date >= Time.zone.today.beginning_of_month
                               project.flow_pressure.to_f
                             else
                               0.0
                             end
    end
    total_flow_pressure
  end

  def money_to_month(projects, required_date)
    active_projects_in_month(projects, required_date).sum(&:money_per_month)
  end

  def search_project_by_full_name(full_name)
    Project.all.select { |p| p.full_name.casecmp(full_name.downcase).zero? }.first
  end

  private

  def where_by_start_end_dates(projects, required_date)
    projects.where('(start_date <= :end_date AND end_date >= :start_date) OR (start_date >= :start_date AND end_date <= :end_date) OR (start_date <= :end_date AND start_date >= :start_date)', start_date: required_date.beginning_of_month, end_date: required_date.end_of_month)
  end
end
