# frozen_string_literal: true

# == Schema Information
#
# Table name: demands
#
#  id                :integer          not null, primary key
#  project_result_id :integer
#  demand_id         :string           not null
#  effort            :decimal(, )
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  demand_type       :integer          not null
#  demand_url        :string
#  commitment_date   :datetime
#  end_date          :datetime
#  created_date      :datetime
#  url               :string
#  class_of_service  :integer          default("standard"), not null
#  project_id        :integer          not null
#  assignees_count   :integer          not null
#
# Indexes
#
#  index_demands_on_project_result_id  (project_result_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#

class Demand < ApplicationRecord
  enum demand_type: { feature: 0, bug: 1, performance_improvement: 2, ux_improvement: 3, chore: 4 }
  enum class_of_service: { standard: 0, expedite: 1, fixed_date: 2, intangible: 3 }

  belongs_to :project
  belongs_to :project_result, counter_cache: true
  has_many :demand_transitions, dependent: :destroy

  validates :project, :demand_id, :demand_type, :class_of_service, :assignees_count, presence: true

  scope :bugs_opened_in_date_count, ->(result_date) { bug.joins(:demand_transitions).having('MIN(DATE(demand_transitions.last_time_in)) = :result_date', result_date: result_date).count }
  scope :finished_in_date, ->(result_date) { joins(demand_transitions: :stage).where('stages.end_point = true AND date(demand_transitions.last_time_in) = :result_date', result_date: result_date) }

  def update_effort!
    effort_transition = demand_transitions.joins(:stage).find_by('stages.compute_effort = true')
    return if effort_transition.blank?
    effort = DemandService.instance.compute_effort_for_dates(effort_transition.last_time_in, effort_transition.last_time_out)
    update(effort: effort)
  end
end
