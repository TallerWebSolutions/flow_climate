# frozen_string_literal: true

class TasksController < AuthenticatedController
  before_action :assign_company

  def index
    @tasks = tasks.order(created_date: :desc)
    @paged_tasks = @tasks.page(page_param)
  end

  def search
    search_tasks
    render 'tasks/index'
  end

  def charts
    search_tasks
    finished_tasks = @tasks.not_discarded_until(Time.zone.now).finished
    @task_completion_control_chart_data = finished_tasks.map { |task| { id: task.external_id, completion_time: task.seconds_to_complete, item_url: company_task_url(@company, task) } }
    @completion_times = @task_completion_control_chart_data.pluck(:completion_time)
    build_tasks_thorughput(finished_tasks)
  end

  def show
    @task = @company.tasks.find(params['id'])
  end

  private

  def build_tasks_thorughput(finished_tasks)
    @tasks_throughputs = Task.where(id: finished_tasks.map(&:id)).group('EXTRACT(week FROM tasks.end_date)').group('EXTRACT(isoyear FROM tasks.end_date)').count.values
    @tasks_throughputs_x_axis = TimeService.instance.weeks_between_of(finished_tasks.map(&:end_date).min, finished_tasks.map(&:end_date).max)
  end

  def search_tasks
    tasks
    @tasks = @tasks.where('title ILIKE :task_name_search', task_name_search: "%#{params['tasks_search']}%") if params['tasks_search'].present?

    @tasks = search_by_status(@tasks) if params['task_status'].present?
    @tasks = search_by_date(@tasks) if params['tasks_start_date'].present? && params['tasks_end_date'].present?

    @paged_tasks = @tasks.page(page_param)
  end

  def search_by_status(tasks)
    return tasks.finished if params['task_status'] == 'finished'
    return tasks.open if params['task_status'] == 'not_finished'

    tasks
  end

  def search_by_date(tasks)
    if params['task_status'] == 'finished'
      tasks.where('tasks.end_date BETWEEN :start_date AND :end_date', start_date: params['tasks_start_date'].to_date.beginning_of_day, end_date: params['tasks_end_date'].to_date.end_of_day)
    else
      tasks.where('tasks.created_date BETWEEN :start_date AND :end_date', start_date: params['tasks_start_date'].to_date.beginning_of_day, end_date: params['tasks_end_date'].to_date.end_of_day)
    end
  end

  def tasks
    @tasks ||= @company.tasks.not_discarded_until(Time.zone.now).order(created_date: :desc)
  end
end
