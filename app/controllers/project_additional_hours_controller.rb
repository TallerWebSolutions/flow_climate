# frozen_string_literal: true

class ProjectAdditionalHoursController < AuthenticatedController
  def new
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end
end
