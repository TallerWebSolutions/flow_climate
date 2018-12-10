# frozen_string_literal: true

# == Schema Information
#
# Table name: user_plans
#
#  active              :boolean          default(FALSE), not null
#  created_at          :datetime         not null
#  finish_at           :datetime         not null
#  id                  :bigint(8)        not null, primary key
#  plan_billing_period :integer          default(0), not null
#  plan_id             :integer          not null, indexed
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
  enum plan_billing_period: { monthly: 0, annualy: 1 }

  belongs_to :user
  belongs_to :plan

  validates :user, :plan, :plan_billing_period, :start_at, :finish_at, presence: true
end
