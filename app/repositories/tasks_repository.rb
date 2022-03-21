# frozen_string_literal: true

class TasksRepository
  include Singleton

  def search(company_id, search_fields = {})
    tasks = Company.find(company_id).tasks.not_discarded_until(Time.zone.now).order(created_date: :desc)

    tasks = search_by_title(tasks, search_fields[:title])
    tasks = search_by_initiative(tasks, search_fields[:initiative_id])
    tasks = search_by_project(tasks, search_fields[:project_id])
    tasks = search_by_team(tasks, search_fields[:team_id])
    tasks = search_by_status(tasks, search_fields[:status])
    search_by_date(tasks, search_fields[:status], search_fields[:from_date], search_fields[:until_date])
  end

  private

  def search_by_title(tasks, title)
    return tasks if title.blank?

    tasks.where('title ILIKE :task_title_search', task_title_search: "%#{title}%")
  end

  def search_by_status(tasks, status)
    tasks = tasks.finished if status == 'finished'
    tasks = tasks.open if status == 'not_finished'

    tasks
  end

  def search_by_project(tasks, project_id)
    return tasks if project_id.blank?

    tasks.joins(:demand).where(demand: { project_id: project_id })
  end

  def search_by_initiative(tasks, initiative_id)
    return tasks if initiative_id.blank?

    tasks.joins(demand: :project).where(demand: { projects: { initiative_id: initiative_id } })
  end

  def search_by_team(tasks, team_id)
    return tasks if team_id.blank?

    tasks.joins(:demand).where(demand: { team_id: team_id })
  end

  def search_by_date(tasks, status, start_date, end_date)
    return tasks unless start_date.present? && end_date.present?

    if status == 'finished'
      tasks.finished_between(start_date, end_date)
    else
      tasks.opened_between(start_date, end_date)
    end
  end
end
