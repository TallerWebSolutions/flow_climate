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
    project.demands.not_finished.each { |demand| demand.update(end_date: finish_date) }
    project.update(status: :finished, end_date: finish_date)
  end
end
