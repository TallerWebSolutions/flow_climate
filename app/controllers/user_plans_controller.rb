# frozen_string_literal: true

class UserPlansController < AuthenticatedController
  before_action :check_admin
  before_action :assign_user
  before_action :assign_user_plan

  def activate_user_plan
    @user_plan.activate
    redirect_to user_path(@user)
  end

  def deactivate_user_plan
    @user_plan.deactivate
    redirect_to user_path(@user)
  end

  def pay_plan
    @user_plan.pay
    redirect_to user_path(@user)
  end

  def unpay_plan
    @user_plan.unpay
    redirect_to user_path(@user)
  end

  private

  def assign_user
    @user = User.find(params[:user_id])
  end

  def assign_user_plan
    @user_plan = UserPlan.find(params[:id])
  end
end
