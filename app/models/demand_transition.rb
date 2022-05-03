# frozen_string_literal: true

# == Schema Information
#
# Table name: demand_transitions
#
#  id                     :bigint           not null, primary key
#  discarded_at           :datetime
#  last_time_in           :datetime         not null
#  last_time_out          :datetime
#  lock_version           :integer
#  transition_notified    :boolean          default(FALSE), not null
#  transition_time_in_sec :integer          default(0)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  demand_id              :integer          not null
#  stage_id               :integer          not null
#  team_member_id         :integer
#
# Indexes
#
#  idx_transitions_unique                           (demand_id,stage_id,last_time_in) UNIQUE
#  index_demand_transitions_on_demand_id            (demand_id)
#  index_demand_transitions_on_discarded_at         (discarded_at)
#  index_demand_transitions_on_stage_id             (stage_id)
#  index_demand_transitions_on_team_member_id       (team_member_id)
#  index_demand_transitions_on_transition_notified  (transition_notified)
#
# Foreign Keys
#
#  fk_rails_2a5bc4c3f8  (demand_id => demands.id)
#  fk_rails_b9c641c4b5  (team_member_id => team_members.id)
#  fk_rails_c63024fc81  (stage_id => stages.id)
#

class DemandTransition < ApplicationRecord
  include Discard::Model

  belongs_to :demand
  belongs_to :stage
  belongs_to :team_member, optional: true

  has_many :demand_efforts, dependent: :destroy

  scope :upstream_transitions, -> { joins(:stage).where('stages.stage_stream' => Stage.stage_streams[:upstream]) }
  scope :downstream_transitions, -> { joins(:stage).where('stages.stage_stream = :stream AND stages.end_point = false', stream: Stage.stage_streams[:downstream]) }
  scope :effort_transitions_to_project, ->(project_id) { joins(stage: :stage_project_configs).where('stage_project_configs.compute_effort = true AND stage_project_configs.project_id = :project_id', project_id: project_id) }
  scope :touch_transitions, -> { joins(:stage).where('stages.queue = false AND stages.end_point = false AND stages.stage_stream = :downstream', downstream: Stage.stage_streams[:downstream]) }
  scope :queue_transitions, -> { joins(:stage).where('stages.queue = true AND stages.end_point = false AND stages.stage_stream = :downstream', downstream: Stage.stage_streams[:downstream]) }
  scope :before_date_after_stage, ->(limit_date, base_order) { joins(:stage).where('last_time_in <= :limit_date AND stages.order >= :stage_order', limit_date: limit_date, stage_order: base_order) }
  scope :for_demands_ids, ->(demands_ids) { where(demand_id: demands_ids) }
  scope :after_date, ->(date) { where('last_time_in >= :limit_date', limit_date: date) }
  scope :for_date, ->(date) { where('(last_time_in <= :limit_date AND (last_time_out IS NULL OR last_time_out >= :limit_date)) OR (last_time_in > :limit_date AND (last_time_out IS NULL OR last_time_out <= :limit_date))', limit_date: date) }

  validates :last_time_in, presence: true

  delegate :name, to: :stage, prefix: true, allow_nil: true

  before_save :compute_transition_time
  after_save :set_demand_dates
  after_save :set_demand_computed_fields
  after_save :check_project_wip

  def total_seconds_in_transition
    out_time = last_time_out || Time.zone.now

    out_time - last_time_in
  end

  def working_time_in_transition
    out_time = [last_time_out, Time.zone.now].compact.min

    TimeService.instance.compute_working_hours_for_dates(last_time_in, out_time)
  end

  def work_time_blocked_in_transition
    last_time_out_to_block = last_time_out || Time.zone.now
    demand.demand_blocks.kept.closed.active.for_date_interval(last_time_in, last_time_out_to_block).filter_map(&:block_working_time_duration).sum
  end

  def time_blocked_in_transition
    last_time_out_to_block = last_time_out || Time.zone.now

    demand.demand_blocks.kept.closed.active.for_date_interval(last_time_in, last_time_out_to_block).filter_map(&:total_blocked_time).sum
  end

  def stage_compute_effort_to_project?
    stage.stage_project_configs.find_by(project: demand.project)&.compute_effort?
  end

  def stage_percentage_to_project
    stage.stage_project_configs.find_by(project: demand.project)&.stage_percentage_decimal
  end

  def stage_pairing_percentage_to_project
    stage.stage_project_configs.find_by(project: demand.project)&.pairing_percentage_decimal
  end

  def stage_management_percentage_to_project
    stage.stage_project_configs.find_by(project: demand.project)&.management_percentage_decimal
  end

  private

  def set_demand_dates
    demand.update(commitment_date: last_time_in) if stage.commitment_area? && !stage.first_end_stage_in_pipe? && demand.commitment_date.blank?

    demand.update(end_date: last_time_in) if stage.first_end_stage_in_pipe?

    demand.update(end_date: nil) if stage.before_end_point?
  end

  def set_demand_computed_fields
    demand.update(total_queue_time: demand_current_queue_time, total_touch_time: demand_current_touch_time, current_stage: current_stage)
    demand.send(:compute_and_update_automatic_fields)
  end

  def demand_current_touch_time
    @demand_current_touch_time ||= demand.demand_transitions.touch_transitions.sum(&:total_seconds_in_transition) - time_blocked_in_touch_transitions
  end

  def demand_current_queue_time
    @demand_current_queue_time ||= demand.demand_transitions.queue_transitions.sum(&:total_seconds_in_transition) + time_blocked_in_touch_transitions
  end

  def time_blocked_in_touch_transitions
    @time_blocked_in_touch_transitions ||= demand.demand_transitions.touch_transitions.sum(&:time_blocked_in_transition)
  end

  def current_stage
    first_stage = demand.team.stages.order(:order).first
    demand.demand_transitions.includes(:stage).order(:last_time_in)&.last&.stage || first_stage
  end

  def check_project_wip
    project = demand.project
    return if project.blank?

    demands_in_wip = project.demands.kept.in_wip(Time.zone.now)
    return if demands_in_wip.count <= project.max_work_in_progress

    ProjectBrokenWipLog.where(project: project, project_wip: project.max_work_in_progress, demands_ids: demands_in_wip.map(&:id)).first_or_create
  end

  def compute_transition_time
    exit_time = last_time_out || Time.zone.now
    self.transition_time_in_sec = exit_time - last_time_in
  end
end
