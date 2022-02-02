# frozen_string_literal: true

class TasksController < AuthenticatedController
  before_action :assign_company

  def index
    @tasks = @company.tasks.order(created_date: :desc)
    @paged_tasks = @tasks.page(page_param)
  end

  def search
    @tasks = @company.tasks.order(created_date: :desc)

    @tasks = @tasks.where('title ILIKE :task_name_search', task_name_search: "%#{params['tasks_search']}%") if params['tasks_search'].present?
    @paged_tasks = @tasks.page(page_param)
    render 'tasks/index'
  end
end
