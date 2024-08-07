# frozen_string_literal: true

class TasksController < AuthenticatedController
  def index
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end

  def charts
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end

  def show
    @task = @company.tasks.kept.find(params['id'])
  end
end
