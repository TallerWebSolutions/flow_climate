# frozen_string_literal: true

class MembershipsController < ApplicationController
  before_action :user_gold_check

  before_action :assign_team

  def index
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end

  def efficiency_table
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end

  def edit
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end

  private

  def assign_team
    @team = @company.teams.find(params[:team_id])
  end
end
