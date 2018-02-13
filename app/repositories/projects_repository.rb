# frozen_string_literal: true

class ProjectsRepository
  include Singleton

  def active_projects_in_month(company, required_date)
    Project.joins(:customer).active.where('customers.company_id = :company_id AND ((start_date <= :end_date AND end_date >= :start_date) OR (start_date >= :start_date AND end_date <= :end_date) OR (start_date <= :end_date AND start_date >= :start_date))', company_id: company.id, start_date: required_date.beginning_of_month, end_date: required_date.end_of_month)
  end

  def hours_consumed_per_month(company, required_date)
    active_projects = active_projects_in_month(company, required_date)
    total_consumed = 0
    active_projects.each { |project| total_consumed += project.project_results.in_month(required_date).sum(&:total_hours) }
    total_consumed
  end

  def flow_pressure_to_month(company, required_date)
    active_projects = active_projects_in_month(company, required_date)
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

  def money_to_month(company, required_date)
    active_projects_in_month(company, required_date).sum(&:money_per_month)
  end

  def known_scope(project, created_date)
    project.demands.where('DATE(created_date) <= :created_date', created_date: created_date).count
  end
end
