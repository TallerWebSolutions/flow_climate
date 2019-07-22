# frozen_string_literal: true

# == Schema Information
#
# Table name: demand_transitions
#
#  created_at    :datetime         not null
#  demand_id     :integer          not null, indexed
#  discarded_at  :datetime         indexed
#  id            :bigint(8)        not null, primary key
#  last_time_in  :datetime         not null
#  last_time_out :datetime
#  stage_id      :integer          not null, indexed
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_demand_transitions_on_demand_id     (demand_id)
#  index_demand_transitions_on_discarded_at  (discarded_at)
#  index_demand_transitions_on_stage_id      (stage_id)
#
# Foreign Keys
#
#  fk_rails_2a5bc4c3f8  (demand_id => demands.id)
#  fk_rails_c63024fc81  (stage_id => stages.id)
#

class DemandTransition < ApplicationRecord
  include Discard::Model

  belongs_to :demand
  belongs_to :stage

  validates :demand, :stage, :last_time_in, presence: true
  validate :same_stage_project?

  delegate :name, to: :stage, prefix: true
  delegate :compute_effort, to: :stage, prefix: true

  scope :upstream_transitions, -> { joins(:stage).where('stages.stage_stream = :stream', stream: Stage.stage_streams[:upstream]) }
  scope :downstream_transitions, -> { joins(:stage).where('stages.stage_stream = :stream AND stages.end_point = false', stream: Stage.stage_streams[:downstream]) }
  scope :effort_transitions_to_project, ->(project_id) { joins(stage: :stage_project_configs).where('stage_project_configs.compute_effort = true AND stage_project_configs.project_id = :project_id', project_id: project_id) }
  scope :touch_transitions, -> { joins(:stage).where('stages.queue = false AND stages.end_point = false AND stages.stage_stream = :downstream', downstream: Stage.stage_streams[:downstream]) }
  scope :queue_transitions, -> { joins(:stage).where('stages.queue = true AND stages.end_point = false AND stages.stage_stream = :downstream', downstream: Stage.stage_streams[:downstream]) }

  after_save :set_demand_dates, on: %i[create update]
  after_save :set_demand_computed_fields, on: %i[create update]

  def total_seconds_in_transition
    out_time = last_time_out
    out_time = Time.zone.now if last_time_out.blank?

    out_time - last_time_in
  end

  def working_time_in_transition
    out_time = last_time_out
    out_time = Time.zone.now if last_time_out.blank?

    TimeService.instance.compute_working_hours_for_dates(last_time_in, out_time)
  end

  private

  def set_demand_dates
    if stage.commitment_point?
      demand.update!(commitment_date: last_time_in)
    elsif stage.first_end_stage_in_pipe?
      demand.update!(end_date: last_time_in)
    elsif stage.before_end_point?
      demand.update!(end_date: nil)
    end
  end

  def set_demand_computed_fields
    current_queue_time = demand.demand_transitions.queue_transitions.sum(&:total_seconds_in_transition)
    current_touch_time = demand.demand_transitions.touch_transitions.sum(&:total_seconds_in_transition)

    demand.update(total_queue_time: current_queue_time, total_touch_time: current_touch_time)
    demand.update_effort!
    demand.send(:compute_and_update_automatic_fields)
  end

  def same_stage_project?
    return if stage.blank? || stage.projects.include?(demand.project)

    errors.add(:stage, I18n.t('activerecord.errors.models.demand_transition.stage.not_same'))
  end
end
