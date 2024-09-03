# frozen_string_literal: true

# == Schema Information
#
# Table name: user_plans
#
#  id                  :bigint           not null, primary key
#  active              :boolean          default(FALSE), not null
#  finish_at           :datetime         not null
#  paid                :boolean          default(FALSE), not null
#  plan_billing_period :integer          default("monthly"), not null
#  plan_value          :decimal(, )      default(0.0), not null
#  start_at            :datetime         not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  plan_id             :integer          not null
#  user_id             :integer          not null
#
# Indexes
#
#  index_user_plans_on_plan_id  (plan_id)
#  index_user_plans_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_406c835a0f  (plan_id => plans.id)
#  fk_rails_6bb6a01b63  (user_id => users.id)
#

class UserPlan < ApplicationRecord
  enum :plan_billing_period, { monthly: 0, yearly: 1 }

  belongs_to :user
  belongs_to :plan

  validates :plan_billing_period, :start_at, :finish_at, :plan_value, presence: true
  validate :user_plan_uniqueness

  scope :valid_plans, -> { where('finish_at >= :limit_date AND start_at <= :limit_date AND active = true AND paid = true', limit_date: Time.zone.now) }
  scope :inactive_in_period, -> { where('finish_at >= :limit_date AND active = false', limit_date: Time.zone.now) }

  delegate :lite?, :trial?, to: :plan

  def description
    "#{plan.plan_type.capitalize} #{plan_billing_period.capitalize}"
  end

  def activate
    update(active: true)
  end

  def deactivate
    update(active: false)
  end

  def pay
    update(paid: true)
  end

  def unpay
    update(paid: false)
  end

  private

  def user_plan_uniqueness
    existent_user_plans = UserPlan.where(user: user, plan: plan).where(finish_at: finish_at..)
    return if existent_user_plans == [self]

    errors.add(:user, I18n.t('user_plan.validations.user_plan_active')) if existent_user_plans.present?
  end
end
