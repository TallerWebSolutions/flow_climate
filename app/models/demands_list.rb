# frozen_string_literal: true

# == Schema Information
#
# Table name: demands_lists
#
#  artifact_type     :integer
#  blocked_time      :float
#  blocks_count      :bigint(8)
#  class_of_service  :integer
#  commitment_date   :datetime
#  created_date      :datetime
#  demand_id         :string
#  demand_title      :string
#  demand_type       :integer
#  discarded_at      :datetime
#  effort_downstream :decimal(, )
#  effort_upstream   :decimal(, )
#  end_date          :datetime
#  id                :bigint(8)        primary key
#  leadtime          :decimal(, )
#  project_id        :bigint(8)
#  project_name      :string
#  queued_time       :float
#  slug              :string
#  total_queue_time  :integer
#  total_touch_time  :integer
#  touch_time        :float
#  url               :string
#

class DemandsList < ApplicationRecord
  include Discard::Model

  self.primary_key = :id

  enum artifact_type: { story: 0, epic: 1, theme: 2 }
  enum demand_type: { feature: 0, bug: 1, performance_improvement: 2, ui: 3, chore: 4, wireframe: 5 }
  enum class_of_service: { standard: 0, expedite: 1, fixed_date: 2, intangible: 3 }

  belongs_to :demand, foreign_key: :id, inverse_of: :demands_list
  belongs_to :project

  scope :finished, -> { kept.where('demands_lists.end_date IS NOT NULL') }
  scope :finished_with_leadtime, -> { kept.story.where('demands_lists.end_date IS NOT NULL AND demands_lists.leadtime IS NOT NULL') }
  scope :in_wip, -> { kept.where('demands_lists.commitment_date IS NOT NULL AND demands_lists.end_date IS NULL') }
  scope :not_started, -> { kept.where('demands_lists.commitment_date IS NULL AND demands_lists.end_date IS NULL') }
  scope :grouped_end_date_by_month, -> { kept.finished.order(end_date: :desc).group_by { |demand| [demand.end_date.to_date.cwyear, demand.end_date.to_date.month] } }
  scope :with_effort, -> { story.where('demands_lists.effort_downstream > 0 OR demands_lists.effort_upstream > 0') }
  scope :to_dates, ->(start_date, end_date) { where('(demands_lists.end_date IS NULL AND demands_lists.created_date BETWEEN :start_date AND :end_date) OR (demands_lists.end_date BETWEEN :start_date AND :end_date)', start_date: start_date.beginning_of_day, end_date: end_date.end_of_day) }

  delegate :portfolio_unit_name, to: :demand, allow_nil: true
  delegate :product_name, to: :demand, allow_nil: true

  def leadtime_in_days
    return 0.0 if leadtime.blank?

    leadtime.to_f / 1.day
  end

  def total_effort
    effort_upstream + effort_downstream
  end
end
