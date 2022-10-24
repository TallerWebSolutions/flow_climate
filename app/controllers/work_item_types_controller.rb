# frozen_string_literal: true

class WorkItemTypesController < AuthenticatedController
  def index
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end

  def new
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end
end
