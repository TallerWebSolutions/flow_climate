# frozen_string_literal: true

class TasksController < AuthenticatedController
  before_action :assign_company

  def index
    @tasks = tasks.order(created_date: :desc)
    @finished_tasks = @tasks.finished
    @paged_tasks = @tasks.page(page_param)
  end

  def search
    search_tasks
    @finished_tasks = @tasks.finished
    render 'tasks/index'
  end

  def charts
    search_tasks
    @finished_tasks = @tasks.finished
    @task_completion_control_chart_data = @finished_tasks.map { |task| { id: task.external_id, completion_time: task.partial_completion_time, item_url: company_task_url(@company, task) } }
    @completion_times = @task_completion_control_chart_data.pluck(:completion_time)

    build_wip_completion_time_control_chart(@tasks, @finished_tasks)

    @tasks_charts_adapter = Highchart::TasksChartsAdapter.new(@tasks.map(&:id), @finished_tasks.map(&:end_date).min, @finished_tasks.map(&:end_date).max)
  end

  def show
    @task = @company.tasks.kept.find(params['id'])
  end

  private

  def build_wip_completion_time_control_chart(tasks, finished_tasks)
    partial_completion_times = (tasks - finished_tasks)
    @task_wip_completion_control_chart_data = partial_completion_times.map { |task| { id: task.external_id, completion_time: task.partial_completion_time, item_url: company_task_url(@company, task) } }
  end

  def search_tasks
    tasks
    @tasks = @tasks.where('title ILIKE :task_name_search', task_name_search: "%#{params['tasks_search']}%") if params['tasks_search'].present?

    search_by_initiative
    search_by_project
    search_by_team
    search_by_status
    search_by_date

    @paged_tasks = @tasks.page(page_param)
  end

  def search_date?
    params['tasks_start_date'].present? && params['tasks_end_date'].present?
  end

  def search_by_status
    return if params['task_status'].blank?

    @tasks = @tasks.finished if params['task_status'] == 'finished'
    @tasks = @tasks.open if params['task_status'] == 'not_finished'
  end

  def search_by_project
    return if params['tasks_project'].blank?

    @tasks = tasks.joins(:demand).where(demand: { project_id: params['tasks_project'] })
  end

  def search_by_initiative
    return if params['tasks_initiative'].blank?

    @tasks = tasks.joins(demand: :project).where(demand: { projects: { initiative_id: params['tasks_initiative'] } })
  end

  def search_by_team
    return if params['tasks_team'].blank?

    @tasks = tasks.joins(:demand).where(demand: { team_id: params['tasks_team'] })
  end

  def search_by_date
    return unless search_date?

    @tasks = if params['task_status'] == 'finished'
               @tasks.finished_between(params['tasks_start_date'], params['tasks_end_date'])
             else
               @tasks.opened_between(params['tasks_start_date'], params['tasks_end_date'])
             end
  end

  def tasks
    @tasks ||= @company.tasks.not_discarded_until(Time.zone.now).order(created_date: :desc)
  end
end
