# frozen_string_literal: true

# == Schema Information
#
# Table name: demand_transitions
#
#  created_at    :datetime         not null
#  demand_id     :integer          not null, indexed
#  id            :bigint(8)        not null, primary key
#  last_time_in  :datetime         not null
#  last_time_out :datetime
#  stage_id      :integer          not null, indexed
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_demand_transitions_on_demand_id  (demand_id)
#  index_demand_transitions_on_stage_id   (stage_id)
#
# Foreign Keys
#
#  fk_rails_2a5bc4c3f8  (demand_id => demands.id)
#  fk_rails_c63024fc81  (stage_id => stages.id)
#

class DemandTransition < ApplicationRecord
  belongs_to :demand
  belongs_to :stage

  validates :demand, :stage, :last_time_in, presence: true
  validate :same_stage_project?

  delegate :name, to: :stage, prefix: true
  delegate :compute_effort, to: :stage, prefix: true

  scope :upstream_transitions, -> { joins(:stage).where('stages.stage_stream = :stream', stream: Stage.stage_streams[:upstream]) }
  scope :downstream_transitions, -> { joins(:stage).where('stages.stage_stream = :stream', stream: Stage.stage_streams[:downstream]) }
  scope :effort_transitions_to_project, ->(project_id) { joins(stage: :stage_project_configs).where('stage_project_configs.compute_effort = true AND stage_project_configs.project_id = :project_id', project_id: project_id) }

  after_save :set_demand_dates, on: %i[create update]
  after_save :set_demand_computed_fields, on: %i[create update]

  def total_hours_in_transition
    return 0 if last_time_out.blank?
    (last_time_out - last_time_in) / 1.hour
  end

  def working_time_in_transition
    return 0 if last_time_out.blank?
    TimeService.instance.compute_working_hours_for_dates(last_time_in, last_time_out)
  end

  private

  def set_demand_dates
    if stage.commitment_point?
      demand.update!(commitment_date: last_time_in)
    elsif stage.first_end_stage_in_pipe?(demand)
      demand.update!(end_date: last_time_in)
    elsif stage.before_end_point?(demand)
      demand.update!(end_date: nil)
    end
  end

  def set_demand_computed_fields
    demand.update(downstream: stage.downstream?, total_queue_time: DemandsRepository.instance.total_queue_time_for(demand), total_touch_time: DemandsRepository.instance.total_touch_time_for(demand))
    demand.update_effort!
  end

  def same_stage_project?
    return if stage.blank? || stage.projects.include?(demand.project)
    errors.add(:stage, I18n.t('activerecord.errors.models.demand_transition.stage.not_same'))
  end
end
