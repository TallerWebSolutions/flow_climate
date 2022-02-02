# frozen_string_literal: true

class TasksController < AuthenticatedController
  before_action :assign_company

  def index
    @tasks = @company.tasks.order(created_date: :desc)
    @paged_tasks = @tasks.page(page_param)
  end

  def search
    search_tasks
    render 'tasks/index'
  end

  def charts
    search_tasks
    finished_tasks = @tasks.finished
    @task_completion_control_chart_data = ScatterData.new(finished_tasks.map(&:seconds_to_complete), finished_tasks.map(&:external_id))
  end

  private

  def search_tasks
    @tasks = @company.tasks.order(created_date: :desc)

    @tasks = @tasks.where('title ILIKE :task_name_search', task_name_search: "%#{params['tasks_search']}%") if params['tasks_search'].present?
    @paged_tasks = @tasks.page(page_param)
  end
end
