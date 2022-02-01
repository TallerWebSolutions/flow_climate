# frozen_string_literal: true

class TasksController < AuthenticatedController
  before_action :assign_company

  def index
    @tasks = @company.tasks.order(created_date: :desc)
    @paged_tasks = @tasks.page(page_param)
  end
end
