# frozen_string_literal: true

# == Schema Information
#
# Table name: plans
#
#  created_at              :datetime         not null
#  id                      :bigint(8)        not null, primary key
#  max_number_of_downloads :integer          not null
#  plan_type               :integer
#  plan_value              :integer
#  updated_at              :datetime         not null
#

class Plan < ApplicationRecord
  enum plan_type: { standard: 0, gold: 1 }

  has_many :user_plans, dependent: :destroy

  validates :plan_type, :max_number_of_downloads, :plan_value, presence: true
end
