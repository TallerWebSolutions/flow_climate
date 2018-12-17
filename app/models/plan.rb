# frozen_string_literal: true

# == Schema Information
#
# Table name: plans
#
#  created_at              :datetime         not null
#  extra_download_value    :decimal(, )      not null
#  id                      :bigint(8)        not null, primary key
#  max_days_in_history     :integer          not null
#  max_number_of_downloads :integer          not null
#  max_number_of_users     :integer          not null
#  plan_details            :string           not null
#  plan_period             :integer          not null
#  plan_type               :integer          not null
#  plan_value              :integer          not null
#  updated_at              :datetime         not null
#

class Plan < ApplicationRecord
  enum plan_type: { trial: 0, lite: 1, gold: 3 }
  enum plan_period: { monthly: 0, yearly: 1 }

  has_many :user_plans, dependent: :destroy

  validates :plan_type, :max_number_of_downloads, :plan_value, :max_number_of_users, :max_days_in_history, :extra_download_value, :plan_period, :plan_details, presence: true

  def yearly_value
    return plan_value if yearly?

    (plan_value * 12) * 0.80
  end

  def monthly_value
    return plan_value if monthly?

    (plan_value / 12.0) * 1.20
  end

  def free?
    plan_value.zero?
  end
end
