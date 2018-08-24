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
#  demand_id         :string           not null, indexed => [project_id]
#  demand_title      :string
#  demand_type       :integer          not null
#  demand_url        :string
#  discarded_at      :datetime         indexed
#  downstream        :boolean          default(TRUE)
#  effort_downstream :decimal(, )      default(0.0)
#  effort_upstream   :decimal(, )      default(0.0)
#  end_date          :datetime
#  id                :bigint(8)        not null, primary key
#  leadtime          :decimal(, )
#  manual_effort     :boolean          default(FALSE)
#  project_id        :integer          not null, indexed => [demand_id]
#  project_result_id :integer          indexed
#  total_queue_time  :integer          default(0)
#  total_touch_time  :integer          default(0)
#  updated_at        :datetime         not null
#  url               :string
#
# Indexes
#
#  index_demands_on_demand_id_and_project_id  (demand_id,project_id) UNIQUE
#  index_demands_on_discarded_at              (discarded_at)
#  index_demands_on_project_result_id         (project_result_id)
#
# Foreign Keys
#
#  fk_rails_19bdd8aa1e  (project_id => projects.id)
#

class Demand < ApplicationRecord
  include Discard::Model

  enum demand_type: { feature: 0, bug: 1, performance_improvement: 2, ui: 3, chore: 4, wireframe: 5 }
  enum class_of_service: { standard: 0, expedite: 1, fixed_date: 2, intangible: 3 }

  belongs_to :project
  belongs_to :project_result, counter_cache: true
  has_many :demand_transitions, dependent: :destroy
  has_many :demand_blocks, dependent: :destroy
  has_many :stages, -> { distinct }, through: :demand_transitions

  validates :project, :created_date, :demand_id, :demand_type, :class_of_service, :assignees_count, presence: true
  validates :demand_id, uniqueness: { scope: :project_id, message: I18n.t('demand.validations.demand_id_unique.message') }

  scope :opened_in_date, ->(date) { where('created_date::timestamp::date = :date', date: date) }
  scope :opened_after_date, ->(date) { where('created_date >= :date', date: date.beginning_of_day) }
  scope :finished_in_stream, ->(stage_stream) { joins(demand_transitions: :stage).where('stages.end_point = true AND stages.stage_stream = :stage_stream', stage_stream: stage_stream).uniq }
  scope :finished, -> { where('end_date IS NOT NULL') }
  scope :finished_with_leadtime, -> { where('end_date IS NOT NULL AND leadtime IS NOT NULL') }
  scope :finished_until_date, ->(limit_date) { finished.where('demands.end_date <= :limit_date', limit_date: limit_date) }
  scope :finished_until_date_with_leadtime, ->(limit_date) { finished_with_leadtime.finished_until_date(limit_date) }
  scope :finished_after_date, ->(limit_date) { finished.where('demands.end_date >= :limit_date', limit_date: limit_date.beginning_of_day) }
  scope :finished_with_leadtime_after_date, ->(limit_date) { finished_with_leadtime.where('demands.end_date >= :limit_date', limit_date: limit_date.beginning_of_day) }
  scope :finished_bugs, -> { bug.finished }
  scope :not_finished, -> { where('end_date IS NULL') }
  scope :grouped_end_date_by_month, -> { finished.order(end_date: :desc).group_by { |demand| [demand.end_date.to_date.cwyear, demand.end_date.to_date.month] } }
  scope :grouped_by_customer, -> { joins(project: :customer).order('customers.name').group_by { |demand| demand.project.customer.name } }
  scope :upstream_flag, -> { where(downstream: false) }
  scope :downstream_flag, -> { where(downstream: true) }
  scope :not_discarded_until_date, ->(limit_date) { where('demands.discarded_at IS NULL OR demands.discarded_at > :limit_date', limit_date: limit_date.end_of_day) }

  delegate :company, to: :project
  delegate :full_name, to: :project, prefix: true

  before_save :compute_and_update_automatic_fields
  after_discard :discard_transitions_and_blocks
  after_undiscard :undiscard_transitions_and_blocks

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
    update(effort_downstream: compute_effort_downstream, effort_upstream: compute_effort_upstream)
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
    demand_transitions.joins(:stage).downstream_transitions.present? || downstream?
  end

  def total_effort
    effort_upstream + effort_downstream
  end

  def current_stage
    demand_transitions.where(last_time_out: nil).order(:last_time_in).last&.stage || demand_transitions.order(:last_time_in)&.last&.stage
  end

  def flowing?
    return false if (current_stage.blank? && commitment_date.blank?) || end_date.present?
    return true if current_stage.blank? && commitment_date.present?
    current_stage.order > current_stage.flow_start_point.order
  end

  def committed?
    return false if (current_stage.blank? && commitment_date.blank?) || end_date.present?
    return true if committed_manually
    current_stage.inside_commitment_area?
  end

  def archived?
    stages.archived.present?
  end

  def update_commitment_date!
    update(commitment_date: nil) if current_stage&.before_commitment_point?
  end

  private

  def compute_effort_upstream
    valid_effort = (working_time_upstream - blocked_working_time_upstream)
    valid_effort *= (project.percentage_effort_to_bugs / 100.0) if bug?
    valid_effort
  end

  def compute_effort_downstream
    valid_effort = (working_time_downstream - blocked_working_time_downstream)
    valid_effort *= (project.percentage_effort_to_bugs / 100.0) if bug?
    valid_effort
  end

  def committed_manually
    current_stage.blank? && commitment_date.present? && end_date.blank?
  end

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

  def discard_transitions_and_blocks
    demand_transitions.discard_all
    demand_blocks.discard_all
  end

  def undiscard_transitions_and_blocks
    demand_transitions.undiscard_all
    demand_blocks.undiscard_all
  end
end
