# frozen_string_literal: true

class TeamMembersController < ApplicationController
  def index
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end

  def show
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end

  def edit
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end
end
