# frozen_string_literal: true
# == Schema Information
#
# Table name: user_plans
#
#  active              :boolean          default(FALSE), not null
#  created_at          :datetime         not null
#  finish_at           :datetime         not null
#  id                  :bigint(8)        not null, primary key
#  paid                :boolean          default(FALSE), not null
#  plan_billing_period :integer          default("monthly"), not null
#  plan_id             :integer          not null, indexed
#  plan_value          :decimal(, )      default(0.0), not null
#  start_at            :datetime         not null
#  updated_at          :datetime         not null
#  user_id             :integer          not null, indexed
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
  enum plan_billing_period: { monthly: 0, yearly: 1 }

  belongs_to :user
  belongs_to :plan

  has_many :demand_data_processments, dependent: :destroy

  validates :user, :plan, :plan_billing_period, :start_at, :finish_at, :plan_value, presence: true
  validate :user_plan_uniqueness

  scope :valid_plans, -> { where('finish_at >= current_date AND start_at <= current_date AND active = true') }
  scope :inactive_in_period, ->(period_limit_date) { where('finish_at >= :limit_date AND active = false', limit_date: period_limit_date) }

  delegate :lite?, to: :plan

  def description
    "#{plan.plan_type.capitalize} #{plan_billing_period.capitalize}"
  end

  private

  def user_plan_uniqueness
    existent_user_plans = UserPlan.where(user: user, plan: plan).where('finish_at >= current_timestamp')
    errors.add(:user, I18n.t('user_plan.validations.user_plan_active')) if existent_user_plans.present?
  end
end
