# frozen_string_literal: true

# == Schema Information
#
# Table name: demands
#
#  id                              :bigint           not null, primary key
#  blocked_working_time_downstream :decimal(, )      default(0.0)
#  blocked_working_time_upstream   :decimal(, )      default(0.0)
#  business_score                  :decimal(, )
#  class_of_service                :integer          default("standard"), not null
#  commitment_date                 :datetime
#  cost_to_project                 :decimal(, )      default(0.0)
#  created_date                    :datetime         not null
#  demand_title                    :string
#  demand_type                     :integer          not null
#  demand_url                      :string
#  discarded_at                    :datetime
#  effort_downstream               :decimal(, )      default(0.0)
#  effort_upstream                 :decimal(, )      default(0.0)
#  end_date                        :datetime
#  external_url                    :string
#  leadtime                        :decimal(, )
#  manual_effort                   :boolean          default(FALSE)
#  slug                            :string
#  total_bloked_working_time       :decimal(, )      default(0.0)
#  total_queue_time                :integer          default(0)
#  total_touch_blocked_time        :decimal(, )      default(0.0)
#  total_touch_time                :integer          default(0)
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  company_id                      :integer          not null
#  current_stage_id                :integer
#  external_id                     :string           not null
#  portfolio_unit_id               :integer
#  product_id                      :integer
#  project_id                      :integer          not null
#  risk_review_id                  :integer
#  service_delivery_review_id      :integer
#  team_id                         :integer          not null
#
# Indexes
#
#  index_demands_on_current_stage_id            (current_stage_id)
#  index_demands_on_discarded_at                (discarded_at)
#  index_demands_on_external_id_and_company_id  (external_id,company_id) UNIQUE
#  index_demands_on_slug                        (slug) UNIQUE
#
# Foreign Keys
#
#  fk_rails_095fb2481e  (team_id => teams.id)
#  fk_rails_19bdd8aa1e  (project_id => projects.id)
#  fk_rails_34f0dad22e  (risk_review_id => risk_reviews.id)
#  fk_rails_35680c72ae  (current_stage_id => stages.id)
#  fk_rails_73cc77780a  (product_id => products.id)
#  fk_rails_c9b5eaaa7f  (portfolio_unit_id => portfolio_units.id)
#  fk_rails_fcc44c0e5d  (service_delivery_review_id => service_delivery_reviews.id)
#

class Demand < ApplicationRecord
  include Discard::Model

  extend FriendlyId
  friendly_id :external_id, use: :slugged

  enum demand_type: { feature: 0, bug: 1, performance_improvement: 2, ui: 3, chore: 4, wireframe: 5 }
  enum class_of_service: { standard: 0, expedite: 1, fixed_date: 2, intangible: 3 }

  belongs_to :company
  belongs_to :project
  belongs_to :product
  belongs_to :portfolio_unit
  belongs_to :team
  belongs_to :risk_review
  belongs_to :service_delivery_review
  belongs_to :current_stage, class_name: 'Stage', foreign_key: :current_stage_id, inverse_of: :current_demands

  has_many :demand_transitions, dependent: :destroy
  has_many :demand_blocks, dependent: :destroy
  has_many :demand_comments, dependent: :destroy
  has_many :item_assignments, dependent: :destroy
  has_many :flow_impacts, dependent: :destroy

  has_many :stages, -> { distinct }, through: :demand_transitions
  has_many :team_members, through: :item_assignments

  validates :project, :created_date, :external_id, :demand_type, :class_of_service, :assignees_count, :team, presence: true
  validates :external_id, uniqueness: { scope: :company_id, message: I18n.t('demand.validations.external_id_unique.message') }

  scope :opened_before_date, ->(date) { where('demands.created_date <= :analysed_date AND (demands.discarded_at IS NULL OR demands.discarded_at > :analysed_date)', analysed_date: date.end_of_day) }
  scope :finished_in_downstream, -> { kept.where('commitment_date IS NOT NULL AND end_date IS NOT NULL') }
  scope :finished_in_upstream, -> { kept.where('commitment_date IS NULL AND end_date IS NOT NULL') }
  scope :finished, -> { kept.where('demands.end_date IS NOT NULL') }
  scope :finished_with_leadtime, -> { kept.where('demands.end_date IS NOT NULL AND demands.leadtime IS NOT NULL') }
  scope :finished_until_date, ->(limit_date) { finished.where('demands.end_date <= :limit_date', limit_date: limit_date) }
  scope :finished_after_date, ->(limit_date) { finished.where('demands.end_date >= :limit_date', limit_date: limit_date) }
  scope :not_finished, -> { kept.where('end_date IS NULL') }
  scope :in_wip, -> { kept.where('demands.commitment_date IS NOT NULL AND demands.end_date IS NULL') }
  scope :to_dates, ->(start_date, end_date) { where('(demands.end_date IS NULL AND demands.created_date BETWEEN :start_date AND :end_date) OR (demands.end_date BETWEEN :start_date AND :end_date)', start_date: start_date.beginning_of_day, end_date: end_date.end_of_day) }
  scope :to_end_dates, ->(start_date, end_date) { where('demands.end_date BETWEEN :start_date AND :end_date', start_date: start_date.beginning_of_day, end_date: end_date.end_of_day) }
  scope :dates_inconsistent_to_project, ->(project) { kept.where('demands.commitment_date < :start_date OR demands.end_date > :end_date', start_date: project.start_date, end_date: project.end_date.end_of_day) }
  scope :unscored_demands, -> { kept.where('demands.business_score IS NULL') }
  scope :with_effort, -> { where('demands.effort_downstream > 0 OR demands.effort_upstream > 0') }
  scope :grouped_end_date_by_month, -> { kept.finished.order(end_date: :desc).group_by { |demand| [demand.end_date.to_date.cwyear, demand.end_date.to_date.month] } }
  scope :not_started, -> { kept.where('demands.commitment_date IS NULL AND demands.end_date IS NULL') }

  delegate :name, to: :project, prefix: true
  delegate :name, to: :product, prefix: true, allow_nil: true
  delegate :name, to: :portfolio_unit, prefix: true, allow_nil: true
  delegate :name, to: :team, prefix: true, allow_nil: true
  delegate :name, to: :current_stage, prefix: true, allow_nil: true
  delegate :count, to: :demand_blocks, prefix: true, allow_nil: true

  before_save :compute_and_update_automatic_fields
  after_discard :discard_dependencies
  after_undiscard :undiscard_dependencies

  def csv_array
    [
      id,
      current_stage_name,
      project_id,
      external_id,
      demand_title,
      demand_type,
      class_of_service,
      decimal_value_to_csv(business_score),
      decimal_value_to_csv(effort_downstream),
      decimal_value_to_csv(effort_upstream)
    ] + build_date_values_array
  end

  def build_date_values_array
    [created_date&.iso8601, commitment_date&.iso8601, end_date&.iso8601]
  end

  def to_hash
    {
      id: id,
      external_id: external_id,
      project_id: project_id,
      demand_title: demand_title,
      business_score: business_score,
      effort_upstream: effort_upstream,
      effort_downstream: effort_downstream,
      cost_to_project: cost_to_project,
      current_stage: current_stage&.name,
      time_in_current_stage: time_in_current_stage,
      partial_leadtime: partial_leadtime,
      responsibles: active_team_members.map(&:to_hash),
      demand_blocks: demand_blocks.map(&:to_hash)
    }
  end

  def active_team_members
    team_members.includes(:item_assignments).where(item_assignments: { finish_time: nil }).uniq
  end

  def update_effort!(update_manual_effort = false)
    return if manual_effort? && !update_manual_effort

    update(effort_downstream: compute_effort_downstream, effort_upstream: compute_effort_upstream)
  end

  def downstream_demand?
    commitment_date.present?
  end

  def total_effort
    effort_upstream + effort_downstream
  end

  def time_in_current_stage
    return 0 if current_stage.blank?

    Time.zone.now - demand_transitions.order(:last_time_in).last.last_time_in
  end

  def flow_percentage_concluded
    return 0 if current_stage.blank? || !downstream_demand?

    stage_orders_array = project.stages.downstream.order(:order).map(&:order)
    return 0 if stage_orders_array.blank?

    stage_orders_array.count { |order| order <= current_stage.order }.to_f / stage_orders_array.count
  end

  def leadtime_in_days
    return 0.0 if leadtime.blank?

    leadtime.to_f / 1.day
  end

  def partial_leadtime
    return leadtime if leadtime.present?
    return 0 if commitment_date.blank?

    Time.zone.now - commitment_date
  end

  def stage_at(analysed_date = Time.zone.now)
    transitions_at = demand_transitions.where('last_time_in <= :analysed_date AND (last_time_out IS NULL OR last_time_out >= :analysed_date)', analysed_date: analysed_date)
    transitions_at&.first&.stage
  end

  def aging_when_finished
    return 0 if end_date.blank?

    (end_date - created_date) / 1.day
  end

  def beyond_limit_time?
    return false if current_stage.blank?

    max_seconds_in_stage = current_stage.stage_project_configs.where(project: project).last.max_seconds_in_stage
    return false if max_seconds_in_stage.zero?

    time_in_current_stage > max_seconds_in_stage
  end

  def product_tree
    return [self] if product.blank?
    return [product, self] if portfolio_unit.blank?

    build_product_tree_array.flatten
  end

  def name
    external_id
  end

  def assignees_count
    active_team_members.count
  end

  def time_between_commitment_and_pull
    return 0 if commitment_date.blank? || commitment_transition.blank? || commitment_transition.last_time_out.blank?

    commitment_transition.last_time_out - commitment_transition.last_time_in
  end

  def blocked_time
    demand_blocks.map(&:total_blocked_time).compact.sum
  end

  private

  def commitment_transition
    commitment_point = stages.find_by(commitment_point: true)

    return nil if commitment_point.blank?

    demand_transitions.where(stage: commitment_point).order(:last_time_in).last
  end

  def build_product_tree_array
    product_tree_array = portfolio_unit.parent_branches
    product_tree_array = product_tree_array.reverse
    product_tree_array.unshift(product)
    product_tree_array << [portfolio_unit, self]
    product_tree_array
  end

  def sum_blocked_time_for_transitions(transitions)
    total_blocked = 0
    transitions.each do |transition|
      total_blocked += demand_blocks.kept.closed.active.for_date_interval(transition.last_time_in, transition.last_time_out).sum(&:total_blocked_time)
    end
    total_blocked
  end

  def decimal_value_to_csv(value)
    value.to_f.to_s.gsub('.', I18n.t('number.format.separator'))
  end

  def compute_effort_upstream
    valid_effort = working_time_upstream
    valid_effort *= (project.percentage_effort_to_bugs / 100.0) if bug?
    valid_effort
  end

  def compute_effort_downstream
    valid_effort = working_time_downstream
    valid_effort *= (project.percentage_effort_to_bugs / 100.0) if bug?
    valid_effort
  end

  def working_time_upstream
    effort_transitions = demand_transitions.kept.upstream_transitions.effort_transitions_to_project(project_id)
    return sum_effort(effort_transitions) if effort_transitions.count.positive?

    0
  end

  def working_time_downstream
    effort_transitions = demand_transitions.kept.downstream_transitions.effort_transitions_to_project(project_id)
    return sum_effort(effort_transitions) if effort_transitions.count.positive?

    0
  end

  def sum_effort(effort_transitions)
    total_effort = 0
    effort_transitions.each { |transition| total_effort += transition.effort_in_transition }
    total_effort
  end

  def compute_and_update_automatic_fields
    self.leadtime = (end_date - commitment_date if commitment_date.present? && end_date.present?)
    self.company = project.company
    self.blocked_working_time_downstream = compute_blocked_working_time_downstream
    self.blocked_working_time_upstream = compute_blocked_working_time_upstream
    self.total_bloked_working_time = compute_total_bloked_working_time
    self.total_touch_blocked_time = compute_total_touch_blocked_time
    self.cost_to_project = compute_cost_to_project
  end

  def compute_total_touch_blocked_time
    sum_blocked_time_for_transitions(demand_transitions.kept.touch_transitions)
  end

  def compute_total_bloked_working_time
    demand_blocks.kept.closed.map(&:block_working_time_duration).compact.sum
  end

  def compute_cost_to_project
    return 0 if project.hour_value.blank?

    (effort_downstream + effort_upstream) * project.hour_value
  end

  def compute_blocked_working_time_downstream
    effort_transitions = demand_transitions.kept.downstream_transitions.effort_transitions_to_project(project_id)
    sum_blocked_effort(effort_transitions)
  end

  def compute_blocked_working_time_upstream
    effort_transitions = demand_transitions.kept.upstream_transitions.effort_transitions_to_project(project_id)
    sum_blocked_effort(effort_transitions)
  end

  def sum_blocked_effort(effort_transitions)
    total_blocked = 0
    effort_transitions.each do |transition|
      total_blocked += demand_blocks.kept.closed.active.for_date_interval(transition.last_time_in, transition.last_time_out).sum(:block_working_time_duration)
    end
    total_blocked
  end

  def discard_dependencies
    demand_transitions.discard_all
    demand_blocks.discard_all
    demand_comments.discard_all
    item_assignments.discard_all
    flow_impacts.discard_all
  end

  def undiscard_dependencies
    demand_transitions.undiscard_all
    demand_blocks.undiscard_all
    demand_comments.undiscard_all
    item_assignments.undiscard_all
    flow_impacts.undiscard_all
  end
end
