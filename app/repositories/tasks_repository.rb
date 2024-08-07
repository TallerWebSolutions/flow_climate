# frozen_string_literal: true

class TasksRepository
  include Singleton

  def search(company_id, page_number, limit = 0, search_fields = {})
    tasks = search_tasks(company_id, search_fields[:initiative_id], search_fields[:project_id], search_fields[:team_id],
                         search_fields[:status], search_fields[:title], search_fields[:from_date], search_fields[:until_date],
                         search_fields[:portfolio_unit_name], search_fields[:task_type])

    return TasksList.new(tasks.count, tasks.finished.count, true, 1, tasks) if tasks.blank?

    process_filled_tasks(limit, page_number, tasks)
  end

  private

  def process_filled_tasks(limit, page_number, tasks)
    query_limit = limit.zero? ? tasks.count : limit

    tasks_page = tasks.order(created_date: :desc).page(page_number).per(query_limit)
    TasksList.new(tasks.count,
                  tasks.finished.count,
                  tasks_page.last_page?,
                  tasks_page.total_pages,
                  tasks_page)
  end

  def search_tasks(company_id, initiative_id, project_id, team_id, status, title, from_date, until_date, portfolio_unit_name, task_type)
    company = Company.find(company_id)
    tasks = company.tasks.not_discarded_until(Time.zone.now)

    tasks = search_by_title(tasks, title)
    tasks = search_by_initiative(tasks, initiative_id)
    tasks = search_by_project(tasks, project_id)
    tasks = search_by_team(tasks, team_id)
    tasks = search_by_status(tasks, status)
    tasks = search_by_portfolio_unit(company, tasks, portfolio_unit_name)
    tasks = search_by_task_type(company, tasks, task_type)

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

  def search_by_portfolio_unit(company, tasks, portfolio_unit_name)
    return tasks if portfolio_unit_name.blank?

    portfolio_units = company.portfolio_units.where('portfolio_units.name ILIKE :unit_name', unit_name: "%#{portfolio_unit_name}%")

    return tasks if portfolio_units.blank?

    unit_tree = portfolio_unit_tree(portfolio_units)

    tasks.joins(demand: :portfolio_unit).where(demands: { portfolio_unit: unit_tree })
  end

  def search_by_task_type(company, tasks, task_type_name)
    return tasks if task_type_name.blank?

    work_item_types = company.work_item_types.where('LOWER(work_item_types.name) = LOWER(:type_name) AND work_item_types.item_level = 1', type_name: task_type_name)

    return tasks if work_item_types.blank?

    tasks.where(work_item_type: work_item_types)
  end

  def portfolio_unit_tree(portfolio_units)
    parent_children = portfolio_units.map(&:children).flatten.uniq
    units_ids = portfolio_units.map(&:id) + parent_children.map(&:id)
    PortfolioUnit.where(id: units_ids.uniq)
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
