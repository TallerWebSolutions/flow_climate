# frozen_string_literal: true

class HomeController < AuthenticatedController
  before_action :authenticate_user!

  def show
    if current_user.lite?
      redirect_to request_project_information_path
    elsif current_user.user_plans.inactive_in_period.present?
      redirect_to user_path(current_user)
    elsif current_user.no_plan?
      redirect_to no_plan_path
    else
      redirect_to user_path(current_user)
    end
  end
end
