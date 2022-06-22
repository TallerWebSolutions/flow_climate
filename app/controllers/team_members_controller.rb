# frozen_string_literal: true

class TeamMembersController < AuthenticatedController
  before_action :assign_company

  def index
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end

  def edit
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end

  def show
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end
end
