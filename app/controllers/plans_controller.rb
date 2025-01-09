# frozen_string_literal: true

class PlansController < ApplicationController
  before_action :inactive_plans_in_period
  skip_before_action :assign_company

  def no_plan; end

  def plan_choose
    plan = Plan.find(params[:plan_id])
    @user = Current.user

    if @inactive_plans.count.positive?
      flash[:alert] = I18n.t('plans.alert.alreary_has_a_plan')
      return redirect_to user_path(Current.user)
    end

    build_plan_to_user(plan, params[:plan_value])
    redirect_to root_path
  end

  private

  def build_plan_to_user(plan, plan_value)
    @user_plan = UserPlan.create(plan: plan, user: Current.user, plan_billing_period: params[:period], plan_value: plan_value, start_at: Time.zone.now, finish_at: plan_finish_date, active: false, paid: false)
    UserNotifierMailer.plan_requested(@user, @user_plan).deliver
  end

  def inactive_plans_in_period
    @inactive_plans = Current.user.user_plans.inactive_in_period
  end

  def plan_finish_date
    @days_from_now = 30
    @days_from_now = 365 if params['period'] == 'yearly'

    @days_from_now.days.from_now
  end
end
