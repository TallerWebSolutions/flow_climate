# frozen_string_literal: true

class PlansController < AuthenticatedController
  before_action :inactive_plans_in_period

  def no_plan; end

  def plan_choose
    plan = Plan.find(params[:plan_id])

    if @inactive_plans.count.positive?
      flash[:alert] = 'Você já tem um plano'
      return redirect_to user_path(current_user)
    end

    UserPlan.create(plan: plan, user: current_user, plan_billing_period: params[:period], plan_value: plan.plan_value, start_at: Time.zone.now, finish_at: plan_finish_date, active: false, paid: false)
    redirect_to root_path
  end

  private

  def inactive_plans_in_period
    @inactive_plans = current_user.user_plans.inactive_in_period(plan_finish_date)
  end

  def plan_finish_date
    @days_from_now = 30
    @days_from_now = 365 if params['period'] == 'yearly'

    @days_from_now.days.from_now
  end
end
