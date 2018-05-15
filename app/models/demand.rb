# frozen_string_literal: true

# == Schema Information
#
# Table name: demands
#
#  assignees_count   :integer          not null
#  class_of_service  :integer          default("standard"), not null
#  commitment_date   :datetime
#  created_at        :datetime         not null
#  created_date      :datetime         not null
#  demand_id         :string           not null
#  demand_type       :integer          not null
#  demand_url        :string
#  downstream        :boolean          default(TRUE)
#  effort_downstream :decimal(, )      default(0.0)
#  effort_upstream   :decimal(, )      default(0.0)
#  end_date          :datetime
#  id                :bigint(8)        not null, primary key
#  leadtime          :decimal(, )
#  manual_effort     :boolean          default(FALSE)
#  project_id        :integer          not null
#  project_result_id :integer          indexed
#  updated_at        :datetime         not null
#  url               :string
#
# Indexes
#
#  index_demands_on_project_result_id  (project_result_id)
#
# Foreign Keys
#
#  fk_rails_19bdd8aa1e  (project_id => projects.id)
#

class Demand < ApplicationRecord
  enum demand_type: { feature: 0, bug: 1, performance_improvement: 2, ux_improvement: 3, chore: 4 }
  enum class_of_service: { standard: 0, expedite: 1, fixed_date: 2, intangible: 3 }

  belongs_to :project
  belongs_to :project_result, counter_cache: true
  has_many :demand_transitions, dependent: :destroy
  has_many :demand_blocks, dependent: :destroy

  validates :project, :created_date, :demand_id, :demand_type, :class_of_service, :assignees_count, presence: true

  scope :opened_in_date, ->(result_date) { where('created_date::timestamp::date = :result_date', result_date: result_date) }
  scope :finished_in_stream, ->(stage_stream) { joins(demand_transitions: :stage).where('stages.end_point = true AND stages.stage_stream = :stage_stream', stage_stream: stage_stream).uniq }
  scope :finished, -> { where('end_date IS NOT NULL') }
  scope :finished_with_leadtime, -> { where('end_date IS NOT NULL AND leadtime IS NOT NULL') }
  scope :finished_bugs, -> { bug.finished }
  scope :grouped_end_date_by_month, -> { finished.order(end_date: :desc).group_by { |demand| [demand.end_date.to_date.cwyear, demand.end_date.to_date.month] } }
  scope :upstream_flag, -> { where(downstream: false) }
  scope :downstream_flag, -> { where(downstream: true) }

  delegate :company, to: :project
  delegate :full_name, to: :project, prefix: true

  before_save :compute_and_update_automatic_fields

  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.find_each do |demand|
        csv << demand.attributes.values_at(*column_names)
      end
    end
  end

  def update_effort!
    return if manual_effort?
    update(effort_downstream: (working_time_downstream - blocked_working_time_downstream), effort_upstream: (working_time_upstream - blocked_working_time_upstream))
  end

  def update_created_date!
    create_transition = demand_transitions.order(:last_time_in).first
    update(created_date: create_transition.last_time_in)
  end

  def result_date
    end_date&.utc&.to_date || created_date.utc.to_date
  end

  def working_time_upstream
    effort_transitions = demand_transitions.upstream_transitions.effort_transitions_to_project(project_id)
    sum_effort(effort_transitions)
  end

  def working_time_downstream
    effort_transitions = demand_transitions.downstream_transitions.effort_transitions_to_project(project_id)
    sum_effort(effort_transitions)
  end

  def blocked_working_time_downstream
    effort_transitions = demand_transitions.downstream_transitions.effort_transitions_to_project(project_id)
    sum_blocked_effort(effort_transitions)
  end

  def blocked_working_time_upstream
    effort_transitions = demand_transitions.upstream_transitions.effort_transitions_to_project(project_id)
    sum_blocked_effort(effort_transitions)
  end

  def downstream_demand?
    demand_transitions.downstream_transitions.present? || downstream?
  end

  def total_effort
    effort_upstream + effort_downstream
  end

  private

  def sum_blocked_effort(effort_transitions)
    total_blocked = 0
    effort_transitions.each do |transition|
      total_blocked += demand_blocks.closed.active.for_date_interval(transition.last_time_in, transition.last_time_out).sum(:block_duration)
    end
    total_blocked
  end

  def sum_effort(effort_transitions)
    total_effort = 0
    effort_transitions.each do |transition|
      stage_config = transition.stage.stage_project_configs.find_by(project: project)
      total_effort += ((compute_effort_in_transition(transition, stage_config) * pairing_value(stage_config))) * (1 + (stage_config.management_percentage / 100.0))
    end
    total_effort
  end

  def compute_effort_in_transition(transition, stage_config)
    TimeService.instance.compute_working_hours_for_dates(transition.last_time_in, transition.last_time_out) * (stage_config.stage_percentage / 100.0)
  end

  def pairing_value(stage_config)
    return assignees_count if assignees_count == 1
    pair_count = assignees_count - 1
    1 + (pair_count * (stage_config.pairing_percentage / 100.0))
  end

  def compute_and_update_automatic_fields
    self.leadtime = end_date - commitment_date if commitment_date.present? && end_date.present?
  end
end
