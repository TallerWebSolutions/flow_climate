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
  end

  def show
    @task = @company.tasks.find(params['id'])
  end

  private

  def search_tasks
    tasks
    @tasks = @tasks.where('title ILIKE :task_name_search', task_name_search: "%#{params['tasks_search']}%") if params['tasks_search'].present?

    if params['task_status'].present?
      @tasks = @tasks.finished if params['task_status'] == 'finished'
      @tasks = @tasks.open if params['task_status'] == 'not_finished'
    end

    @paged_tasks = @tasks.page(page_param)
  end

  def tasks
    @tasks ||= @company.tasks.not_discarded_until(Time.zone.now).order(created_date: :desc)
  end
end
