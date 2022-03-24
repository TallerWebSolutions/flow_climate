# frozen_string_literal: true

class TasksController < AuthenticatedController
  before_action :assign_company

  def index
    prepend_view_path Rails.root.join('public')
    render 'spa-build/index'
  end

  def charts
    prepend_view_path Rails.root.join('public')
    render 'spa-build/index'
  end

  def show
    @task = @company.tasks.kept.find(params['id'])
  end
end
