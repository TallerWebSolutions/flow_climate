# frozen_string_literal: true

# == Schema Information
#
# Table name: demands
#
#  id                :integer          not null, primary key
#  project_result_id :integer          not null
#  demand_id         :string           not null
#  effort            :decimal(, )      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  demand_type       :integer          not null
#  demand_url        :string
#  commitment_date   :datetime
#  end_date          :datetime
#  created_date      :datetime         not null
#  url               :string
#  class_of_service  :integer          default("standard"), not null
#
# Indexes
#
#  index_demands_on_project_result_id  (project_result_id)
#

class Demand < ApplicationRecord
  enum demand_type: { feature: 0, bug: 1, performance_improvement: 2, ux_improvement: 3, chore: 4 }
  enum class_of_service: { standard: 0, expedite: 1, fixed_date: 2, intangible: 3 }

  belongs_to :project_result, counter_cache: true

  validates :project_result, :created_date, :demand_id, :effort, :demand_type, :class_of_service, presence: true
end
