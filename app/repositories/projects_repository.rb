# frozen_string_literal: true

class ProjectsRepository
  include Singleton

  def add_query_to_projects_in_status(projects, status_param)
    projects_with_query_and_order = projects
    projects_with_query_and_order = projects.where(status: status_param) if status_param != 'all'
    projects_with_query_and_order.order(end_date: :desc)
  end

  def projects_ending_after(projects, limit_date)
    projects.where('end_date >= :limit_date', limit_date: limit_date)
  end

  def finish_project(project, finish_date = Time.zone.now)
    project.demands.kept.not_finished(Time.zone.now).each { |demand| demand.update(end_date: finish_date) }
    project.update(status: :finished, end_date: finish_date)
  end

  def search(company_id, search_fields = {})
    projects = Company.find(company_id).projects
    search_projects(projects,
                    search_fields[:project_name],
                    search_fields[:project_status],
                    search_fields[:start_date],
                    search_fields[:end_date])
  end

  private

  def search_projects(projects, project_name, project_status, start_date, end_date)
    projects = projects.where('name ILIKE :name', name: "%#{project_name.tr(' ', '%')}%") if project_name.present?
    projects = projects.where(status: project_status) if project_status.present?
    projects = projects.where('start_date >= :start_date', start_date: start_date) if start_date.present?
    projects = projects.where('end_date <= :end_date', end_date: end_date) if end_date.present?
    projects.order(end_date: :desc)
  end
end
