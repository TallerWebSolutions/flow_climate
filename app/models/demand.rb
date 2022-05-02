# frozen_string_literal: true

# == Schema Information
#
# Table name: demands
#
#  id                                   :bigint           not null, primary key
#  class_of_service                     :integer          default("standard"), not null
#  commitment_date                      :datetime
#  cost_to_project                      :decimal(, )      default(0.0)
#  created_date                         :datetime         not null
#  demand_score                         :decimal(, )      default(0.0)
#  demand_tags                          :string           default([]), is an Array
#  demand_title                         :string
#  demand_type                          :integer          not null
#  demand_url                           :string
#  discarded_at                         :datetime
#  effort_design                        :decimal(, )      default(0.0), not null
#  effort_development                   :decimal(, )      default(0.0), not null
#  effort_downstream                    :decimal(, )      default(0.0)
#  effort_management                    :decimal(, )      default(0.0), not null
#  effort_upstream                      :decimal(, )      default(0.0)
#  end_date                             :datetime
#  external_url                         :string
#  lead_time_percentile_project_ranking :float
#  leadtime                             :decimal(, )
#  manual_effort                        :boolean          default(FALSE)
#  slug                                 :string
#  total_bloked_working_time            :decimal(, )      default(0.0)
#  total_queue_time                     :integer          default(0)
#  total_touch_blocked_time             :decimal(, )      default(0.0)
#  total_touch_time                     :integer          default(0)
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  company_id                           :integer          not null
#  contract_id                          :integer
#  current_stage_id                     :integer
#  customer_id                          :integer
#  external_id                          :string           not null
#  portfolio_unit_id                    :integer
#  product_id                           :integer
#  project_id                           :integer
#  risk_review_id                       :integer
#  service_delivery_review_id           :integer
#  team_id                              :integer          not null
#
# Indexes
#
#  index_demands_on_contract_id                 (contract_id)
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
#  fk_rails_b14b9efb68  (customer_id => customers.id)
#  fk_rails_c9b5eaaa7f  (portfolio_unit_id => portfolio_units.id)
#  fk_rails_d084bb511c  (contract_id => contracts.id)
#  fk_rails_fcc44c0e5d  (service_delivery_review_id => service_delivery_reviews.id)
#

class Demand < ApplicationRecord
  include Discard::Model

  paginates_per 20

  extend FriendlyId
  friendly_id :external_id, use: :slugged

  enum demand_type: { feature: 0, bug: 1, performance_improvement: 2, ui: 3, chore: 4, wireframe: 5 }
  enum class_of_service: { standard: 0, expedite: 1, fixed_date: 2, intangible: 3 }

  belongs_to :company
  belongs_to :project
  belongs_to :product, optional: true
  belongs_to :team
  belongs_to :customer, optional: true
  belongs_to :portfolio_unit, optional: true
  belongs_to :risk_review, optional: true
  belongs_to :service_delivery_review, optional: true
  belongs_to :contract, optional: true
  belongs_to :current_stage, class_name: 'Stage', inverse_of: :current_demands, optional: true

  has_many :demand_transitions, dependent: :destroy
  has_many :demand_blocks, dependent: :destroy
  has_many :demand_comments, dependent: :destroy
  has_many :item_assignments, dependent: :destroy
  has_many :demand_efforts, dependent: :destroy

  has_many :stages, -> { distinct }, through: :demand_transitions
  has_many :memberships, through: :item_assignments
  has_many :demand_score_matrices, dependent: :destroy
  has_many :jira_api_errors, dependent: :destroy, class_name: 'Jira::JiraApiError'
  has_many :class_of_service_change_histories, class_name: 'History::ClassOfServiceChangeHistory', dependent: :destroy
  has_many :tasks, dependent: :destroy

  validates :created_date, :external_id, :demand_type, :class_of_service, :assignees_count, presence: true
  validates :external_id, uniqueness: { scope: :company_id, message: I18n.t('demand.validations.external_id_unique.message') }

  scope :opened_before_date, ->(date) { where('demands.created_date <= :analysed_date AND (demands.discarded_at IS NULL OR demands.discarded_at > :analysed_date)', analysed_date: date.end_of_day) }
  scope :finished_in_downstream, -> { where('commitment_date IS NOT NULL AND end_date IS NOT NULL') }
  scope :finished_in_upstream, -> { where('commitment_date IS NULL AND end_date IS NOT NULL') }
  scope :finished_with_leadtime, -> { where('demands.end_date IS NOT NULL AND demands.leadtime IS NOT NULL') }
  scope :finished_until_date, ->(limit_date) { where('(demands.end_date <= :limit_date)', limit_date: limit_date) }
  scope :finished_after_date, ->(limit_date) { where('(demands.end_date >= :limit_date)', limit_date: limit_date) }
  scope :not_started, ->(limit_date) { joins(demand_transitions: :stage).where('stages.order = 0 and (demand_transitions.last_time_out IS NULL OR demand_transitions.last_time_out > :limit_date)', limit_date: limit_date).uniq }
  scope :not_committed, ->(limit_date) { where('(demands.commitment_date IS NULL OR demands.commitment_date > :limit_date) AND (demands.end_date IS NULL OR demands.end_date > :limit_date)', limit_date: limit_date) }
  scope :not_finished, ->(limit_date) { where('(demands.end_date IS NULL OR demands.end_date > :limit_date)', limit_date: limit_date) }
  scope :not_discarded_until, ->(limit_date) { where('demands.discarded_at IS NULL OR demands.discarded_at > :limit_date', limit_date: limit_date) }
  scope :in_wip, ->(limit_date) { where('(demands.commitment_date <= :limit_date) AND (demands.end_date IS NULL OR demands.end_date > :limit_date)', limit_date: limit_date) }
  scope :in_flow, ->(limit_date) { joins(:demand_transitions).where('(demands.end_date IS NULL OR demands.end_date > :limit_date)', limit_date: limit_date).group('demands.id').having('COUNT(demand_transitions.id) > 1') }
  scope :to_dates, ->(start_date, end_date) { where('(demands.end_date IS NOT NULL AND demands.end_date BETWEEN :start_date AND :end_date) OR (demands.end_date IS NULL AND demands.commitment_date IS NOT NULL AND demands.commitment_date BETWEEN :start_date AND :end_date) OR (demands.end_date IS NULL AND demands.commitment_date IS NULL AND demands.created_date BETWEEN :start_date AND :end_date)', start_date: start_date.beginning_of_day, end_date: end_date.end_of_day) }
  scope :until_date, ->(limit_date) { where('(demands.end_date IS NOT NULL AND demands.end_date <= :limit_date) OR (demands.commitment_date IS NOT NULL AND demands.commitment_date <= :limit_date) OR (demands.created_date <= :limit_date)', limit_date: limit_date) }
  scope :to_end_dates, ->(start_date, end_date) { where('demands.end_date BETWEEN :start_date AND :end_date', start_date: start_date.beginning_of_day, end_date: end_date.end_of_day) }
  scope :dates_inconsistent_to_project, ->(project) { where('demands.commitment_date < :start_date OR demands.end_date > :end_date', start_date: project.start_date, end_date: project.end_date.end_of_day) }
  scope :scored_demands, -> { where('demands.demand_score > 0') }
  scope :unscored_demands, -> { where('demands.demand_score = 0') }
  scope :with_effort, -> { where('demands.effort_downstream > 0 OR demands.effort_upstream > 0') }
  scope :grouped_end_date_by_month, -> { where.not(demands: { end_date: nil }).order(end_date: :desc).group_by { |demand| [demand.end_date.to_date.cwyear, demand.end_date.to_date.month] } }
  scope :with_valid_leadtime, -> { where('demands.leadtime >= :leadtime_data_limit', leadtime_data_limit: 10.minutes.to_i) }
  scope :for_team_member, ->(member) { joins(item_assignments: { membership: :team_member }).where(item_assignments: { memberships: { team_members: member } }).uniq }

  delegate :name, to: :project, prefix: true, allow_nil: true
  delegate :name, to: :product, prefix: true, allow_nil: true
  delegate :name, to: :customer, prefix: true, allow_nil: true
  delegate :name, to: :portfolio_unit, prefix: true, allow_nil: true
  delegate :name, to: :team, prefix: true, allow_nil: true
  delegate :name, to: :current_stage, prefix: true, allow_nil: true
  delegate :count, to: :demand_blocks, prefix: true, allow_nil: true

  before_save :compute_and_update_automatic_fields
  before_save :compute_lead_time
  after_create :decrease_uncertain_scope

  after_discard :discard_dependencies
  after_undiscard :undiscard_dependencies

  def csv_array
    [
      id,
      portfolio_unit_name,
      current_stage_name,
      project_id,
      project_name,
      external_id,
      demand_title,
      demand_type,
      class_of_service,
      decimal_value_to_csv(demand_score),
      decimal_value_to_csv(effort_downstream),
      decimal_value_to_csv(effort_upstream),
      decimal_value_to_csv(partial_leadtime)
    ] + build_date_values_array
  end

  def build_date_values_array
    [created_date&.iso8601, commitment_date&.iso8601, end_date&.iso8601]
  end

  def to_hash
    {
      id: id, portfolio_unit: portfolio_unit_name, external_id: external_id, project_id: project_id, demand_title: demand_title,
      demand_score: demand_score, effort_upstream: effort_upstream, effort_downstream: effort_downstream, cost_to_project: cost_to_project,
      current_stage: current_stage&.name, time_in_current_stage: time_in_current_stage, partial_leadtime: partial_leadtime,
      responsibles: active_team_members.map(&:to_hash), demand_blocks: demand_blocks.map(&:to_hash)
    }
  end

  def date_to_use
    end_date || commitment_date || created_date
  end

  def active_team_members
    memberships.includes([:team_member]).where(item_assignments: { finish_time: nil }).uniq
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
    demand_transitions_at(analysed_date)&.first&.stage
  end

  def demand_transitions_at(analysed_date = Time.zone.now)
    demand_transitions.where('last_time_in <= :analysed_date AND (last_time_out IS NULL OR last_time_out >= :analysed_date)', analysed_date: analysed_date)
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

  def first_stage_in_the_flow
    first_stage = team.stages.where('stages.order >= 0').order(:order).first
    return first_stage if first_stage.present?

    project.stages.where('stages.order >= 0').order(:order).first
  end

  def not_committed?
    commitment_date.blank? && end_date.blank?
  end

  def stages_at(start_time, finish_time)
    if finish_time.present?
      demand_transitions.includes([:stage]).where('((last_time_in <= :finish_time) AND (last_time_out >= :start_time)) OR (last_time_out IS NULL AND last_time_in <= :finish_time)', start_time: start_time, finish_time: finish_time).map(&:stage).uniq
    else
      demand_transitions.includes([:stage]).where('(last_time_out IS NULL) OR (last_time_out >= :start_time)', start_time: start_time, finish_time: finish_time).map(&:stage).uniq
    end
  end

  def discard_with_date(date)
    update(discarded_at: date)
    demand_transitions.update(discarded_at: date)
    demand_blocks.update(discarded_at: date)
    demand_comments.update(discarded_at: date)
    item_assignments.update(discarded_at: date)
    tasks.update(discarded_at: date)
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

  def decimal_value_to_csv(value)
    value.to_f.to_s.gsub('.', I18n.t('number.format.separator'))
  end

  def compute_and_update_automatic_fields
    self.cost_to_project = compute_cost_to_project
    self.lead_time_percentile_project_ranking = Stats::StatisticsService.instance.percentile_for_lead_time(partial_leadtime, project.demands.finished_with_leadtime.map(&:leadtime))
  end

  def compute_lead_time
    self.leadtime = (end_date - commitment_date if commitment_date.present? && end_date.present?)
  end

  def compute_cost_to_project
    return 0 if project&.hour_value.blank?

    (effort_downstream + effort_upstream) * project.hour_value
  end

  def discard_dependencies
    demand_transitions.discard_all
    demand_blocks.discard_all
    demand_comments.discard_all
    item_assignments.discard_all
    tasks.discard_all
  end

  def undiscard_dependencies
    demand_transitions.undiscard_all
    demand_blocks.undiscard_all
    demand_comments.undiscard_all
    item_assignments.undiscard_all
    tasks.undiscard_all
  end

  def decrease_uncertain_scope
    return if project.blank?

    current_initial_scope = project.initial_scope

    return if current_initial_scope <= 0

    project.update(initial_scope: (current_initial_scope - 1))
  end
end
