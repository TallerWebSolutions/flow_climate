# frozen_string_literal: true

class TasksRepository
  include Singleton

  def search(company_id, page_number, limit, search_fields = {})
    tasks = search_tasks(company_id, search_fields[:initiative_id], search_fields[:project_id], search_fields[:team_id],
                         search_fields[:status], search_fields[:title], search_fields[:from_date], search_fields[:until_date])

    tasks_page = tasks.order(created_date: :desc).page(page_number).per(limit)
    TasksList.new(tasks.count,
                  tasks.finished.count,
                  tasks_page.last_page?,
                  tasks_page.total_pages,
                  tasks_page)
  end

  private

  def search_tasks(company_id, initiative_id, project_id, team_id, status, title, from_date, until_date)
    tasks = Company.find(company_id).tasks.not_discarded_until(Time.zone.now)

    tasks = search_by_title(tasks, title)
    tasks = search_by_initiative(tasks, initiative_id)
    tasks = search_by_project(tasks, project_id)
    tasks = search_by_team(tasks, team_id)
    tasks = search_by_status(tasks, status)

    search_by_date(tasks, status, from_date, until_date)
  end

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
